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

const EXPECTED_LOG_ENTRY = "lambda-job-example completed successfully"

func TestScheduledLambdaJob(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "examples/scheduled-lambda-job")
	terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, testFolder)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	checkLogsForSuccessfulLambdaJobExecution(t, terraformOptions, awsRegion)
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
				if strings.Contains(entry, EXPECTED_LOG_ENTRY) {
					return entry, nil
				}
			}
		}

		return "", fmt.Errorf("Did not find entry '%s' in CloudWatch Logs", EXPECTED_LOG_ENTRY)
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
