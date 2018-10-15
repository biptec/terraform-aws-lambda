package test

import (
	"testing"
	"fmt"
	"io/ioutil"
	"github.com/aws/aws-sdk-go/service/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	terraws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/logger"
	"time"
	"github.com/gruntwork-io/terratest/modules/retry"
)

var regionsWithoutLambda = []string{
	"us-west-1",
	"sa-east-1",
	"ap-southeast-1",
	"ap-south-1",
	"ca-central-1", // Has lambda, but is incredibly slow, so tests often time out
}

func createBaseTerraformOptions(t *testing.T, templatePath string) (*terraform.Options, string, string) {
	awsRegion := terraws.GetRandomRegion(t, nil, regionsWithoutLambda)
	uniqueId := random.UniqueId()

	terraformOptions := terraform.Options{
		TerraformDir: templatePath,
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
			"name": fmt.Sprintf("%s-%s", t.Name(), uniqueId),
		},
		RetryableTerraformErrors: map[string]string{
			"the KMS key is invalid for CreateGrant": "https://github.com/terraform-providers/terraform-provider-aws/issues/4633",
		},
		MaxRetries: 3,
	}

	return &terraformOptions, awsRegion, uniqueId
}

func readFileAsString(t *testing.T, filePath string) string {
	out, err := ioutil.ReadFile(filePath)
	if err != nil {
		t.Fatalf("Failed to read file %s: %v", filePath, err)
	}
	return string(out)
}

func triggerLambdaFunctionWithCustomAction(t *testing.T, functionName string, payload []byte, awsRegion string, action func(string) (string, error)) string {
	description := fmt.Sprintf("Trigger lambda function %s", functionName)
	maxRetries := 10
	timeBetweenRetries := 5 * time.Second

	// We have to retry Lambda invocations due to some strange, intermittent error that has appeared recently:
	// "AccessDeniedException: The role defined for the function cannot be assumed by Lambda."
	return retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		out, err := triggerLambdaFunctionE(t, functionName, payload, awsRegion)
		if err != nil {
			return "", err
		}
		return action(string(out))
	})
}

func triggerLambdaFunction(t *testing.T, functionName string, payload []byte, awsRegion string) string {
	identity := func(str string) (string, error) { return str, nil }
	return triggerLambdaFunctionWithCustomAction(t, functionName, payload, awsRegion, identity)
}

func triggerLambdaFunctionE(t *testing.T, functionName string, payload []byte, awsRegion string) ([]byte, error) {
	logger.Logf(t, "Invoking lambda function %s", functionName)

	sess, err := terraws.NewAuthenticatedSession(awsRegion)
	if err != nil {
		return nil, err
	}

	lambdaClient := lambda.New(sess)

	input := lambda.InvokeInput{
		FunctionName: aws.String(functionName),
		Payload: payload,
	}

	output, err := lambdaClient.Invoke(&input)
	if err != nil {
		return nil, err
	}

	return output.Payload, nil
}
