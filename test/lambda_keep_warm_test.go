package test

import (
	"testing"
	terraws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/aws"
	"gopkg.in/go-playground/assert.v1"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"time"
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

		// The warm-up function runs once per minute and the lambda functions it invokes take ~5 seconds to run, so
		// sleep a little over a minute to make sure everything is completed by the time we run our checks
		sleepTime := 70 * time.Second

		logger.Logf(t, "Sleeping for %s to give the warm-up function time to run the first time", sleepTime)
		time.Sleep(sleepTime)

		assertFunctionsHaveBeenInvoked(t, awsRegion, terraformOptions, concurrency, 1)

		logger.Logf(t, "Sleeping for %s to give the warm-up function time to run the second time", sleepTime)
		time.Sleep(sleepTime)

		assertFunctionsHaveBeenInvoked(t, awsRegion, terraformOptions, concurrency, 2)

		logger.Logf(t, "Sleeping for %s to give the warm-up function time to run the third time", sleepTime)
		time.Sleep(sleepTime)

		assertFunctionsHaveBeenInvoked(t, awsRegion, terraformOptions, concurrency, 3)
	})
}

func assertFunctionsHaveBeenInvoked(t *testing.T, awsRegion string, terraformOptions *terraform.Options, concurrency int, expectedNumInvocations int) {
	sess, err := terraws.NewAuthenticatedSession(awsRegion)
	if err != nil {
		t.Fatal(err)
	}

	dynamodbClient := dynamodb.New(sess)

	dynamoDBTableName := terraform.OutputRequired(t, terraformOptions, "dynamodb_table_name")
	functionName1 := terraform.OutputRequired(t, terraformOptions, "lambda_example_1_function_name")
	functionName2 := terraform.OutputRequired(t, terraformOptions, "lambda_example_2_function_name")

	input := dynamodb.ScanInput{
		ConsistentRead: aws.Bool(true),
		TableName:      aws.String(dynamoDBTableName),
	}

	out, err := dynamodbClient.Scan(&input)

	if err != nil {
		t.Fatal(err)
	}

	// Count how many times each function was invoked and how many unique function IDs were found. Each function ID
	// represents a new Docker container concurrently running and being kept "warm."
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

	invocationsFunc1 := invocations[functionName1]
	invocationsFunc2 := invocations[functionName2]

	logger.Logf(t, "Invocations for %s: %v", functionName1, invocationsFunc1)
	logger.Logf(t, "Invocations for %s: %v", functionName2, invocationsFunc2)

	assert.Equal(t, expectedNumInvocations * concurrency, invocationsFunc1.Count)
	assert.Equal(t, expectedNumInvocations * concurrency, invocationsFunc2.Count)
	assert.Equal(t, concurrency, len(invocationsFunc1.FunctionIds))
	assert.Equal(t, concurrency, len(invocationsFunc2.FunctionIds))
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

