package test

import (
	"encoding/json"
	"fmt"
	"reflect"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestLambdaS3DeploymentPackage(t *testing.T) {
	t.Parallel()

	terraformOptions, awsRegion, uniqueId := createBaseTerraformOptions(t, "../examples/lambda-s3-deployment-package")
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.OutputRequired(t, terraformOptions, "function_name")

	event, requestPayload := createEventForEchoLambdaFunction(t, uniqueId)

	responsePayload := triggerLambdaFunction(t, functionName, requestPayload, awsRegion)
	assertResponsePayloadUnchanged(t, event, []byte(responsePayload))
}

func createEventForEchoLambdaFunction(t *testing.T, uniqueId string) (map[string]string, []byte) {
	event := map[string]string{
		"text": fmt.Sprintf("test-%s", uniqueId),
	}

	logger.Logf(t, "Using event object %v as request payload to Lambda function.", event)

	out, err := json.Marshal(event)
	if err != nil {
		t.Fatalf("Failed to convert event object %v to JSON: %v", event, err)
	}

	return event, out
}

func assertResponsePayloadUnchanged(t *testing.T, expectedEvent map[string]string, responsePayload []byte) {
	actualEvent := map[string]string{}
	if err := json.Unmarshal(responsePayload, &actualEvent); err != nil {
		t.Fatalf("Failed to parse response as JSON: %v", err)
	}
	if reflect.DeepEqual(expectedEvent, actualEvent) {
		logger.Logf(t, "Got expected event back: %v", actualEvent)
	} else {
		t.Fatalf("Expected to get back event %v but got %v", expectedEvent, actualEvent)
	}
}
