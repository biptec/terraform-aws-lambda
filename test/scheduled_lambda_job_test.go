package test

import (
	"testing"
	"github.com/gruntwork-io/terratest"
	"github.com/aws/aws-sdk-go/service/cloudwatchlogs"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"fmt"
	"github.com/gruntwork-io/terratest/util"
	terraaws "github.com/gruntwork-io/terratest/aws"
	terralog "github.com/gruntwork-io/terratest/log"
	"time"
	"log"
	"strings"
)

const EXPECTED_LOG_ENTRY = "lambda-job-example completed successfully"

func TestScheduledLambdaJob(t *testing.T) {
	t.Parallel()

	testName := "TestScheduledLambdaJob"
	logger := terralog.NewLogger(testName)

	resourceCollection := createBaseRandomResourceCollection(t)
	terratestOptions := createBaseTerratestOptions(testName, "../examples/scheduled-lambda-job", resourceCollection)
	defer terratest.Destroy(terratestOptions, resourceCollection)

	if _, err := terratest.Apply(terratestOptions); err != nil {
		t.Fatalf("Failed to apply templates in %s due to error: %s\n", terratestOptions.TemplatePath, err.Error())
	}

	checkLogsForSuccessfulLambdaJobExecution(t, terratestOptions, resourceCollection, logger)
}

func checkLogsForSuccessfulLambdaJobExecution(t *testing.T, terratestOptions *terratest.TerratestOptions, resourceCollection *terratest.RandomResourceCollection, logger *log.Logger) {
	lambdaFunctionName := getRequiredOutput(t, "function_name", terratestOptions)

	_, err := util.DoWithRetry("Looking in CloudWatch Logs to see if the lambda job executed successfully", 10, 30 * time.Second, logger, func() (string, error) {
		logStreamNames, err := getLambdaJobLogStreamNames(t, lambdaFunctionName, resourceCollection)
		if err != nil {
			return "", err
		}

		logGroupName := formatLogGroupName(lambdaFunctionName)
		for _, logStreamName := range logStreamNames {
			entries, err := terraaws.GetCloudWatchLogEntries(resourceCollection.AwsRegion, logStreamName, logGroupName)
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

	if err != nil {
		t.Fatalf("Failed to find entry '%s' in CloudWatch logs after 10 retries: %v", EXPECTED_LOG_ENTRY, err)
	}
}

func getLambdaJobLogStreamNames(t *testing.T, lambdaFunctionName string, resourceCollection *terratest.RandomResourceCollection) ([]string, error) {
	svc := cloudwatchlogs.New(session.New(), aws.NewConfig().WithRegion(resourceCollection.AwsRegion))
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