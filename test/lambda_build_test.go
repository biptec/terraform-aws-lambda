package test

import (
	"testing"
	"encoding/json"
	"strings"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestLambdaBuild(t *testing.T) {
	t.Parallel()

	buildDeploymentPackage(t)

	terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, "../examples/lambda-build")
	defer terraform.Destroy(t, terraformOptions)

	terraform.Apply(t, terraformOptions)

	functionName := terraform.OutputRequired(t, terraformOptions, "function_name")
	requestPayload := createPayloadFormLambdaBuildFunction(t)

	responsePayload := triggerLambdaFunction(t, functionName, requestPayload, awsRegion)
	assertValidResponsePayload(t, responsePayload)
}

func buildDeploymentPackage(t *testing.T) {
	logger.Logf(t, "Building deployment package for lambda-build example")
	cmd := shell.Command{Command: "../examples/lambda-build/python/build.sh"}
	shell.RunCommand(t, cmd)
}

func createPayloadFormLambdaBuildFunction(t *testing.T) []byte {
	event := map[string]string{
		"url": "http://www.example.com",
	}

	logger.Logf(t, "Using event object %v as request payload to Lambda function.", event)

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