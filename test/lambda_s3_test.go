package test

import (
	"crypto/md5"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/biptec/terratest/modules/logger"
	"github.com/biptec/terratest/modules/terraform"
	test_structure "github.com/biptec/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestLambdaS3(t *testing.T) {
	LambdaS3Test(t, nil)
}

func LambdaS3Test(t *testing.T, reservedConcurrentExecutions *int) {
	t.Parallel()

	terraformDir := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/lambda-s3")
	terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, terraformDir)
	invocationType := "RequestResponse"
	defer terraform.Destroy(t, terraformOptions)

	if reservedConcurrentExecutions != nil {
		terraformOptions.Vars["reserved_concurrent_executions"] = *reservedConcurrentExecutions
	}
	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.OutputRequired(t, terraformOptions, "function_name")
	requestPayload := createEventObjectPayloadForLambdaFunction(t, terraformOptions, awsRegion)

	actualBase64Data := triggerLambdaFunctionWithCustomAction(t, functionName, requestPayload, invocationType, awsRegion, func(responsePayload string) (string, error) {
		return getBase64ImageDataFromResponsePayloadE(t, []byte(responsePayload))
	})

	expectedBase64Data := readFileAsString(t, "gruntwork-logo.base64.txt")

	// We use a md5 checksum for printing purposes, as terratest_log_parser has a bug where it can't read in the entire
	// base64 string
	// https://github.com/gruntwork-io/terratest/issues/203

	if expectedBase64Data == actualBase64Data {
		expectedHashedData := md5.Sum([]byte(expectedBase64Data))
		logger.Logf(t, "Got back expected base 64 data from the lambda function! MD5 hash of data:\n%x", expectedHashedData)
	} else {
		expectedHashedData := md5.Sum([]byte(expectedBase64Data))
		actualHashedData := md5.Sum([]byte(actualBase64Data))
		t.Fatalf("Did not get back expected base64 data. MD5 hash of data - Expected:\n%x\nActual:\n%x", expectedHashedData, actualHashedData)
	}

	// Verify perpetual diff issue https://github.com/gruntwork-io/package-lambda/issues/26
	exitCode := terraform.PlanExitCode(t, terraformOptions)
	assert.Equal(t, exitCode, 0)
}

func getBase64ImageDataFromResponsePayloadE(t *testing.T, payload []byte) (string, error) {
	logger.Logf(t, "Parsing response payload from Lambda function to extract base64-encoded image data.")

	response := map[string]string{}
	if err := json.Unmarshal(payload, &response); err != nil {
		return "", fmt.Errorf("Failed to parse response payload from Lambda function. Error: %v. Payload: %s.", err, string(payload))
	}

	base64Data, hasBase64Data := response["image_base64"]
	if !hasBase64Data {
		return "", fmt.Errorf("Response payload did not contain base 64 image data! %v", response)
	}

	return base64Data, nil
}

func createEventObjectPayloadForLambdaFunction(t *testing.T, terraformOptions *terraform.Options, awsRegion string) []byte {
	s3BucketName := terraform.OutputRequired(t, terraformOptions, "s3_bucket_name")
	imageFileName := terraform.OutputRequired(t, terraformOptions, "image_filename")

	event := map[string]string{
		"aws_region":     awsRegion,
		"s3_bucket":      s3BucketName,
		"image_filename": imageFileName,
	}

	logger.Logf(t, "Using event object %v as request payload to Lambda function.", event)

	out, err := json.Marshal(event)
	if err != nil {
		t.Fatalf("Failed to convert event object %v to JSON: %v", event, err)
	}

	return out
}
