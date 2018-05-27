package test

import (
	"testing"
	terraws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"time"
	"fmt"
	"github.com/gruntwork-io/terratest/modules/retry"
	"strings"
	"github.com/stretchr/testify/assert"
)

const savedAwsRegion = "AwsRegion"

func TestLambdaKeepWarm1(t *testing.T) {
	t.Parallel()
	testLambdaKeepWarm(t, 1)
}

func TestLambdaKeepWarm5(t *testing.T) {
	t.Parallel()
	testLambdaKeepWarm(t, 5)
}

func testLambdaKeepWarm(t *testing.T, concurrency int) {
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/lambda-keep-warm")

	defer test_structure.RunTestStage(t, "teardown", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	defer test_structure.RunTestStage(t, "logs", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		awsRegion := test_structure.LoadString(t, testFolder, savedAwsRegion)

		logger.Logf(t, "Sleeping for a little while to allow log data to propagate")
		time.Sleep(30 * time.Second)

		printLogs(t, terraformOptions, awsRegion, "keep_warm_function_name")
		printLogs(t, terraformOptions, awsRegion, "lambda_example_1_function_name")
		printLogs(t, terraformOptions, awsRegion, "lambda_example_2_function_name")
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, testFolder)

		// Have the keep-warm function invoke the other Lambda functions once per minute. Each invocation has a concurrency
		// of 5, so 5 requests should be sent to each of the other Lambda functions concurrently.
		terraformOptions.Vars["schedule_expression"] = "rate(1 minute)"
		terraformOptions.Vars["concurrency"] = concurrency

		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		test_structure.SaveString(t, testFolder, savedAwsRegion, awsRegion)

		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		awsRegion := test_structure.LoadString(t, testFolder, savedAwsRegion)

		// The Lambda functions should run once per minute, and they take 5 seconds to execute, so adding some buffer,
		// we should never have to wait longer than this
		maxWaitTime := 75 * time.Second

		assertFunctionsHaveBeenInvoked(t, awsRegion, terraformOptions, concurrency, 1, maxWaitTime)
		assertFunctionsHaveBeenInvoked(t, awsRegion, terraformOptions, concurrency, 2, maxWaitTime)
		assertFunctionsHaveBeenInvoked(t, awsRegion, terraformOptions, concurrency, 3, maxWaitTime)
	})
}

func printLogs(t *testing.T, terraformOptions *terraform.Options, awsRegion string, functionNameOutput string) {
	lambdaFunctionName := terraform.OutputRequired(t, terraformOptions, functionNameOutput)
	description := fmt.Sprintf("Getting CloudWatch Logs for lambda function %s", lambdaFunctionName)
	maxRetries := 10
	timeBetweenRetries := 30 * time.Second

	logs := retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		logStreamNames, err := getLambdaJobLogStreamNames(t, lambdaFunctionName, awsRegion)
		if err != nil {
			return "", err
		}

		logEntries := []string{}

		logGroupName := formatLogGroupName(lambdaFunctionName)
		for _, logStreamName := range logStreamNames {
			entries, err := terraws.GetCloudWatchLogEntriesE(t, awsRegion, logStreamName, logGroupName)
			if err != nil {
				return "", err
			}

			logEntries = append(logEntries, entries...)
		}

		return strings.Join(logEntries, ""), nil
	})

	logger.Logf(t, "Log entries for lambda function %s:\n\n%s\n\n", lambdaFunctionName, logs)
}

func assertFunctionsHaveBeenInvoked(t *testing.T, awsRegion string, terraformOptions *terraform.Options, concurrency int, expectedNumInvocations int, maxTimeElapsed time.Duration) {
	dynamoDBTableName := terraform.OutputRequired(t, terraformOptions, "dynamodb_table_name")
	functionName1 := terraform.OutputRequired(t, terraformOptions, "lambda_example_1_function_name")
	functionName2 := terraform.OutputRequired(t, terraformOptions, "lambda_example_2_function_name")

	description := fmt.Sprintf("Wait until Lambda functions %s and %s have been invoked %d times each", functionName1, functionName2, expectedNumInvocations)
	maxRetries := 36
	timeBetweenRetries := 5 * time.Second
	start := time.Now()

	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		dynamoDbData, err := getDataFromDynamoDb(t, dynamoDBTableName, awsRegion)
		if err != nil {
			t.Fatal(err)
		}

		invocationsFunc1, invocationsFunc2 := countInvocations(t, dynamoDbData, functionName1, functionName2)

		logger.Logf(t, "Invocations for %s: %v", functionName1, invocationsFunc1)
		logger.Logf(t, "Invocations for %s: %v", functionName2, invocationsFunc2)

		if err := invocationsFunc1.Validate(concurrency, expectedNumInvocations); err != nil {
			return "", err
		}

		if err := invocationsFunc2.Validate(concurrency, expectedNumInvocations); err != nil {
			return "", err
		}

		return fmt.Sprintf("Lambda functions %s and %s have been invoked %d times each", functionName1, functionName2, expectedNumInvocations), nil
	})

	timeElapsed := time.Since(start)
	assert.True(t, timeElapsed < maxTimeElapsed, "Expected that less than %s time has passed since starting these checks, but it actually took %s", maxTimeElapsed, timeElapsed)
}

func getDataFromDynamoDb(t *testing.T, dynamoDbTableName string, awsRegion string) (*dynamodb.ScanOutput, error) {
	sess, err := terraws.NewAuthenticatedSession(awsRegion)
	if err != nil {
		return nil, err
	}

	dynamodbClient := dynamodb.New(sess)

	input := dynamodb.ScanInput{
		ConsistentRead: aws.Bool(true),
		TableName:      aws.String(dynamoDbTableName),
	}

	return dynamodbClient.Scan(&input)
}

// Count how many times each function was invoked and how many unique function IDs were found. Each function ID
// represents a new Docker container concurrently running and being kept "warm."
func countInvocations(t *testing.T, out *dynamodb.ScanOutput, functionName1 string, functionName2 string) (*Invocations, *Invocations) {
	invocations := map[string]*Invocations{
		functionName1: NewInvocations(),
		functionName2: NewInvocations(),
	}

	for _, item := range out.Items {
		functionId := getRequiredDynamoDbValue(t, item, "FunctionId")
		functionName := getRequiredDynamoDbValue(t, item, "FunctionName")

		invocation, containsInvocation := invocations[functionName]
		if !containsInvocation {
			t.Fatalf("Unexpected function name found in DynamoDB table: %s", functionName)
		}

		invocation.Count += 1
		invocation.FunctionIds[functionId] = true
	}

	return invocations[functionName1], invocations[functionName2]
}

func getRequiredDynamoDbValue(t *testing.T, item map[string]*dynamodb.AttributeValue, key string) string {
	value, containsValue := item[key]
	if !containsValue {
		t.Fatalf("DynamoDB Item %v does not contain required key %s", item, key)
	}

	return aws.StringValue(value.S)
}

// Simple struct used to track how many times a Lambda function was invoked and the unique function IDs used with that
// function. Each function ID represents a Docker container being kept warm for that function.
type Invocations struct {
	Count       int
	FunctionIds map[string]bool
}

func NewInvocations() *Invocations {
	return &Invocations{
		Count:       0,
		FunctionIds: map[string]bool{},
	}
}

func (invocations *Invocations) Validate(concurrency int, expectedNumInvocations int) error {
	expectedTotalInvocations := expectedNumInvocations * concurrency
	if expectedTotalInvocations != invocations.Count {
		return fmt.Errorf("Expected %d invocations but got %d", expectedTotalInvocations, invocations.Count)
	}

	if concurrency != len(invocations.FunctionIds) {
		return fmt.Errorf("Expected a concurrency of %d, but found %d unique function IDs", concurrency, len(invocations.FunctionIds))
	}

	return nil
}