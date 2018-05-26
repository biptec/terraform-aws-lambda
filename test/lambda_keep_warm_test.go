package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/logger"
	"time"
	"encoding/json"
)

func TestLambdaKeepWarm(t *testing.T) {
	t.Parallel()

	terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, "../examples/lambda-keep-warm")

	// Have the keep-warm function invoke the other Lambda functions once per minute. Each invocation has a concurrency
	// of 5, so 5 requests should be sent to each of the other Lambda functions concurrently.
	terraformOptions.Vars["schedule_expression"] = "rate(1 minute)"
	terraformOptions.Vars["concurrency"] = 5

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	logger.Logf(t, "Sleeping for a minute to give the warm-up function time to run the first time")
	time.Sleep(1 * time.Minute)

	assertFunctionHasBeenInvoked(t, "lambda_example_1_function_name", terraformOptions, awsRegion, 1)
	assertFunctionHasBeenInvoked(t, "lambda_example_2_function_name", terraformOptions, awsRegion, 1)

	logger.Logf(t, "Sleeping for a minute to give the warm-up function time to run the second time")
	time.Sleep(1 * time.Minute)

	assertFunctionHasBeenInvoked(t, "lambda_example_1_function_name", terraformOptions, awsRegion, 2)
	assertFunctionHasBeenInvoked(t, "lambda_example_2_function_name", terraformOptions, awsRegion, 2)

	logger.Logf(t, "Sleeping for a minute to give the warm-up function time to run the third time")
	time.Sleep(1 * time.Minute)

	assertFunctionHasBeenInvoked(t, "lambda_example_1_function_name", terraformOptions, awsRegion, 3)
	assertFunctionHasBeenInvoked(t, "lambda_example_2_function_name", terraformOptions, awsRegion, 3)
}

type KeepWarmExampleResponse struct {
	FunctionId      string
	InvocationCount int
}

func assertFunctionHasBeenInvoked(t *testing.T, functionNameOutput string, terraformOptions *terraform.Options, awsRegion string, expectedInvocations int) {
	request := map[string]string{"type": "test"}
	requestPayload, err := json.Marshal(request)
	if err != nil {
		t.Fatal(err)
	}

	lambdaFunctionName := terraform.OutputRequired(t, terraformOptions, functionNameOutput)
	responsePayload := triggerLambdaFunction(t, lambdaFunctionName, requestPayload, awsRegion)

	logger.Logf(t, "Response from function %s: %s", lambdaFunctionName, string(responsePayload))

	var response KeepWarmExampleResponse
	if err := json.Unmarshal(responsePayload, &response); err != nil {
		t.Fatal(err)
	}

	if response.InvocationCount != expectedInvocations {
		t.Fatalf("Expected function %s to have been invoked %d times, but got %d invocations", lambdaFunctionName, expectedInvocations, response.InvocationCount)
	}
}
