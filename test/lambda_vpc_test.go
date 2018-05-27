package test

import (
	"testing"
	"log"
	"encoding/json"
)

// TODO: There is a Terraform bug that causes `terraform destroy` to fail for lambda functions in VPCs. As a result,
// we have to disable this test: https://github.com/hashicorp/terraform/issues/10272
//
//func TestLambdaVpc(t *testing.T) {
//	t.Parallel()
//
//	testName := "TestLambdaVpc"
//	logger := terralog.NewLogger(testName)
//
//	resourceCollection := createBaseRandomResourceCollection(t)
//	terratestOptions := createBaseTerraformOptions(testName, "../examples/lambda-vpc", resourceCollection)
//	defer terratest.Destroy(terratestOptions, resourceCollection)
//
//	terratestOptions.Vars["vpc_name"] = fmt.Sprintf("lambda-vpc-example-%s", resourceCollection.UniqueId)
//
//	if _, err := terratest.Apply(terratestOptions); err != nil {
//		t.Fatalf("Failed to apply templates in %s due to error: %s\n", terratestOptions.TemplatePath, err.Error())
//	}
//
//	functionName := getRequiredOutput(t, "function_name", terratestOptions)
//
//	responsePayload := triggerLambdaFunction(t, functionName, []byte{}, resourceCollection, logger)
//	response := getResponseFromPayload(t, responsePayload, logger)
//
//	logger.Printf("Got response from lambda function:\n%s", response)
//
//	if !strings.Contains(response, "Example Domain") {
//		t.Fatal("Response did not contain expected text 'Example Domain'")
//	}
//}

func getResponseFromPayload(t *testing.T, payload []byte, logger *log.Logger) string {
	logger.Println("Parsing response from payload from Lambda function.")

	response := map[string]string{}
	if err := json.Unmarshal(payload, &response); err != nil {
		t.Fatalf("Failed to unmarshal response payload from lambda function as map: %v", err)
	}

	responseStr, hasResponse := response["response"]
	if !hasResponse {
		t.Fatalf("Payload did not contain response data! %v", response)
	}

	return responseStr
}