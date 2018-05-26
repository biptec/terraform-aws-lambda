package test

import (
	"testing"
	"encoding/json"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/logger"
)

func TestLambdaS3(t *testing.T) {
	t.Parallel()

	terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, "../examples/lambda-s3")
	defer terraform.Destroy(t, terraformOptions)

	terraform.Apply(t, terraformOptions)

	functionName := terraform.OutputRequired(t, terraformOptions, "function_name")
	requestPayload := createEventObjectPayloadForLambdaFunction(t, terraformOptions, awsRegion)

	responsePayload := triggerLambdaFunction(t, functionName, requestPayload, awsRegion)
	actualBase64Data := getBase64ImageDataFromResponsePayload(t, responsePayload)
	expectedBase64Data := readFileAsString(t, "gruntwork-logo.base64.txt")

	if expectedBase64Data == actualBase64Data {
		logger.Logf(t, "Got back expected base 64 data from the lambda function!\n%s", actualBase64Data)
	} else {
		t.Fatalf("Did not get back expected base64 data. Expected:\n%s\nActual:\n%s", expectedBase64Data, actualBase64Data)
	}
}

func getBase64ImageDataFromResponsePayload(t *testing.T, payload []byte) string {
	logger.Logf(t, "Parsing response payload from Lambda function to extract base64-encoded image data.")

	response := map[string]string{}
	if err := json.Unmarshal(payload, &response); err != nil {
		t.Fatalf("Failed to unmarshal response payload '%s' from lambda function as map: %v", string(payload), err)
	}

	base64Data, hasBase64Data := response["image_base64"]
	if !hasBase64Data {
		t.Fatalf("Response payload did not contain base 64 image data! %v", response)
	}

	return base64Data
}

func createEventObjectPayloadForLambdaFunction(t *testing.T, terraformOptions *terraform.Options, awsRegion string) []byte {
	s3BucketName := terraform.OutputRequired(t, terraformOptions, "s3_bucket_name")
	imageFileName := terraform.OutputRequired(t, terraformOptions, "image_filename")

	event := map[string]string{
		"aws_region": awsRegion,
		"s3_bucket": s3BucketName,
		"image_filename": imageFileName,
	}

	logger.Logf(t, "Using event object %v as request payload to Lambda function.", event)

	out, err := json.Marshal(event)
	if err != nil {
		t.Fatalf("Failed to convert event object %v to JSON: %v", event, err)
	}

	return out
}