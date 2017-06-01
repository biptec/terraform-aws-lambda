package test

import (
	"github.com/gruntwork-io/terratest"
	"testing"
	terralog "github.com/gruntwork-io/terratest/log"
	"github.com/gruntwork-io/terratest/shell"
	"log"
	"encoding/json"
	"strings"
)

func TestLambdaBuild(t *testing.T) {
	t.Parallel()

	testName := "TestLambdaBuild"
	logger := terralog.NewLogger(testName)

	buildDeploymentPackage(t, logger)

	resourceCollection := createBaseRandomResourceCollection(t)
	terratestOptions := createBaseTerratestOptions(testName, "../examples/lambda-build", resourceCollection)
	defer terratest.Destroy(terratestOptions, resourceCollection)

	if _, err := terratest.Apply(terratestOptions); err != nil {
		t.Fatalf("Failed to apply templates in %s due to error: %s\n", terratestOptions.TemplatePath, err.Error())
	}

	functionName := getRequiredOutput(t, "function_name", terratestOptions)
	requestPayload := createPayloadFormLambdaBuildFunction(t, logger)

	responsePayload := triggerLambdaFunction(t, functionName, requestPayload, resourceCollection, logger)
	assertValidResponsePayload(t, responsePayload)
}

func buildDeploymentPackage(t *testing.T, logger *log.Logger) {
	logger.Println("Building deployment package for lambda-build example")

	cmd := shell.Command{Command: "../examples/lambda-build/python/build.sh"}

	if err := shell.RunCommand(cmd, logger); err != nil {
		t.Fatalf("Failed to build deployment package: %v", err)
	}
}

func createPayloadFormLambdaBuildFunction(t *testing.T, logger *log.Logger) []byte {
	event := map[string]string{
		"url": "http://www.example.com",
	}

	logger.Printf("Using event object %v as request payload to Lambda function.", event)

	out, err := json.Marshal(event)
	if err != nil {
		t.Fatalf("Failed to convert event object %v to JSON: %v", event, err)
	}

	return out
}

type ResponsePayload struct {
	Status int
	Body   string
}

func assertValidResponsePayload(t *testing.T, payload []byte) {
	response := ResponsePayload{}
	if err := json.Unmarshal(payload, &response); err != nil {
		t.Fatalf("Failed to unmarshal response payload from lambda function as map: %v", err)
	}

	if response.Status != 200 {
		t.Fatalf("Expected status 200 but got %d", response.Status)
	}
	if !strings.Contains(response.Body, "Example Domain") {
		t.Fatalf("Resonse body did not contain expected text: %s", response.Body)
	}
}