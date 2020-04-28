package test

import (
	"crypto/md5"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"testing"
)

func TestLambdaS3Reserved(t *testing.T) {
	t.Parallel()

	terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, "../examples/lambda-s3-reserved")
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.OutputRequired(t, terraformOptions, "function_name")
	requestPayload := createEventObjectPayloadForLambdaFunction(t, terraformOptions, awsRegion)

	actualBase64Data := triggerLambdaFunctionWithCustomAction(t, functionName, requestPayload, awsRegion, func(responsePayload string) (string, error) {
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
