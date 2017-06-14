package test

import (
	"github.com/gruntwork-io/terratest"
	"testing"
	terralog "github.com/gruntwork-io/terratest/log"
	"encoding/json"
	"fmt"
	"log"
	"github.com/stretchr/testify/assert"
)

func TestLambdaS3DeploymentPackage(t *testing.T) {
	t.Parallel()

	testName := "TestLambdaS3DeploymentPackage"
	logger := terralog.NewLogger(testName)

	resourceCollection := createBaseRandomResourceCollection(t)
	terratestOptions := createBaseTerratestOptions(testName, "../examples/lambda-s3-deployment-package", resourceCollection)
	defer terratest.Destroy(terratestOptions, resourceCollection)

	if _, err := terratest.Apply(terratestOptions); err != nil {
		t.Fatalf("Failed to apply templates in %s due to error: %s\n", terratestOptions.TemplatePath, err.Error())
	}

	functionName := getRequiredOutput(t, "function_name", terratestOptions)

	event, requestPayload := createEventForEchoLambdaFunction(t, resourceCollection, logger)
	responsePayload := triggerLambdaFunction(t, functionName, requestPayload, resourceCollection, logger)

	assertResponsePayloadUnchanged(t, event, responsePayload)
}

func createEventForEchoLambdaFunction(t *testing.T, resourceCollection *terratest.RandomResourceCollection, logger *log.Logger) (map[string]string, []byte) {
	event := map[string]string{
		"text": fmt.Sprintf("test-%s", resourceCollection.UniqueId),
	}

	logger.Printf("Using event object %v as request payload to Lambda function.", event)

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
	assert.Equal(t, expectedEvent, actualEvent, "Expected function to echo back the request payload unchanged")
}