package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
	terraws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

const lambdaJobExpectedLogEntry = "lambda-job-example completed successfully"

func TestScheduledLambdaJob(t *testing.T) {
	t.Parallel()

	// Uncomment any of the following to skip that stage
	//os.Setenv("SKIP_setup", "true")
	//os.Setenv("SKIP_apply", "true")
	//os.Setenv("SKIP_validate", "true")
	//os.Setenv("SKIP_destroy", "true")

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "examples/scheduled-lambda-job")

	defer test_structure.RunTestStage(t, "destroy", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, testFolder, terraformOptions)
		test_structure.SaveString(t, testFolder, "region", awsRegion)
	})

	test_structure.RunTestStage(t, "apply", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate", func() {
		terraformOptions := test_structure.LoadTerraformOptions(t, testFolder)
		awsRegion := test_structure.LoadString(t, testFolder, "region")
		checkLogsForSuccessfulLambdaJobExecution(t, terraformOptions, awsRegion)
	})
}

func TestScheduledLambdaJobCreateResourcesFalse(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "examples/scheduled-lambda-job")
	terraformOptions, _, _ := createBaseTerraformOptions(t, testFolder)
	terraformOptions.Vars["create_resources"] = false
	planOut := terraform.InitAndPlan(t, terraformOptions)
	resourceCounts := terraform.GetResourceCount(t, planOut)
	assert.Equal(t, resourceCounts.Add, 0)
	assert.Equal(t, resourceCounts.Change, 0)
	assert.Equal(t, resourceCounts.Destroy, 0)
}

func checkLogsForSuccessfulLambdaJobExecution(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	lambdaFunctionName := terraform.OutputRequired(t, terraformOptions, "function_name")
	requireExpectedLogEntry(t, lambdaFunctionName, awsRegion, lambdaJobExpectedLogEntry)
	requireExpectedLogEntry(t, lambdaFunctionName, awsRegion, fmt.Sprintf(`"uniqueID": "%s"`, lambdaFunctionName))
}

func requireExpectedLogEntry(t *testing.T, lambdaFunctionName, awsRegion, expectedLogEntry string) {
	description := "Looking in CloudWatch Logs to see if the lambda job executed successfully"
	maxRetries := 10
	timeBetweenRetries := 30 * time.Second

	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		logStreamNames, err := getLambdaJobLogStreamNames(t, lambdaFunctionName, awsRegion)
		if err != nil {
			return "", err
		}

		logGroupName := formatLogGroupName(lambdaFunctionName)
		for _, logStreamName := range logStreamNames {
			entries, err := terraws.GetCloudWatchLogEntriesE(t, awsRegion, logStreamName, logGroupName)
			if err != nil {
				return "", err
			}

			for _, entry := range entries {
				if strings.Contains(entry, expectedLogEntry) {
					return entry, nil
				}
			}
		}

		return "", fmt.Errorf("Did not find entry '%s' in CloudWatch Logs", expectedLogEntry)
	})
}

func getLambdaJobLogStreamNames(t *testing.T, lambdaFunctionName string, awsRegion string) ([]string, error) {
	sess, err := terraws.NewAuthenticatedSession(awsRegion)
	if err != nil {
		t.Fatal(err)
	}

	svc := cloudwatchlogs.New(sess)
	input := cloudwatchlogs.DescribeLogStreamsInput{LogGroupName: aws.String(formatLogGroupName(lambdaFunctionName))}

	output, err := svc.DescribeLogStreams(&input)
	if err != nil {
		return []string{}, err
	}

	logStreamNames := []string{}
	for _, logStream := range output.LogStreams {
		logStreamNames = append(logStreamNames, *logStream.LogStreamName)
	}

	return logStreamNames, nil
}

func formatLogGroupName(lambdaFunctionName string) string {
	return fmt.Sprintf("/aws/lambda/%s", lambdaFunctionName)
}
