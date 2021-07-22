package test

import (
	"fmt"
	"io/ioutil"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/lambda"
	terraws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

const (
	maxTerraformRetries          = 3
	sleepBetweenTerraformRetries = 5 * time.Second
)

var (
	// Set up terratest to retry on known failures
	retryableTerraformErrors = map[string]string{
		// `terraform init` frequently fails in CI due to network issues accessing plugins. The reason is unknown, but
		// eventually these succeed after a few retries.
		".*unable to verify signature.*":             "Failed to retrieve plugin due to transient network error.",
		".*unable to verify checksum.*":              "Failed to retrieve plugin due to transient network error.",
		".*no provider exists with the given name.*": "Failed to retrieve plugin due to transient network error.",
		".*registry service is unreachable.*":        "Failed to retrieve plugin due to transient network error.",

		"the KMS key is invalid for CreateGrant": "https://github.com/terraform-providers/terraform-provider-aws/issues/4633",
	}

	regionsWithoutLambda = []string{
		"us-west-1",
		"sa-east-1",
		"ap-southeast-1",
		"ap-south-1",

		// Has lambda, but is incredibly slow, so tests often time out
		"ca-central-1",

		// Has lambda, but due to a Terraform bug, leads to a "code signing config AccessDeniedException" error
		// https://github.com/hashicorp/terraform-provider-aws/issues/16755
		// https://github.com/hashicorp/terraform-provider-aws/issues/18328
		"ap-northeast-3",
	}
)

func createBaseTerraformOptions(t *testing.T, templatePath string) (*terraform.Options, string, string) {
	awsRegion := terraws.GetRandomRegion(t, nil, regionsWithoutLambda)
	uniqueId := random.UniqueId()
	testName := strings.Replace(t.Name(), "/", "-", -1)

	terraformOptions := terraform.Options{
		TerraformDir: templatePath,
		Vars: map[string]interface{}{
			"aws_region": awsRegion,
			"name":       fmt.Sprintf("%s-%s", testName, uniqueId),
		},
		RetryableTerraformErrors: retryableTerraformErrors,
		MaxRetries:               maxTerraformRetries,
		TimeBetweenRetries:       sleepBetweenTerraformRetries,
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

func triggerLambdaFunctionWithCustomAction(t *testing.T, functionName string, payload []byte, invocationType string, awsRegion string, action func(string) (string, error)) string {
	description := fmt.Sprintf("Trigger lambda function %s", functionName)
	maxRetries := 10
	timeBetweenRetries := 5 * time.Second

	// We have to retry Lambda invocations due to some strange, intermittent error that has appeared recently:
	// "AccessDeniedException: The role defined for the function cannot be assumed by Lambda."
	return retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		out, err := triggerLambdaFunctionE(t, functionName, payload, invocationType, awsRegion)
		if err != nil {
			return "", err
		}
		return action(string(out))
	})
}

func triggerLambdaFunction(t *testing.T, functionName string, payload []byte, awsRegion string) string {
	identity := func(str string) (string, error) { return str, nil }
	return triggerLambdaFunctionWithCustomAction(t, functionName, payload, "RequestResponse", awsRegion, identity)
}

func triggerLambdaFunctionAsync(t *testing.T, functionName string, payload []byte, awsRegion string) string {
	identity := func(str string) (string, error) { return str, nil }
	return triggerLambdaFunctionWithCustomAction(t, functionName, payload, "Event", awsRegion, identity)
}

func triggerLambdaFunctionE(t *testing.T, functionName string, payload []byte, invocationType string, awsRegion string) ([]byte, error) {
	logger.Logf(t, "Invoking lambda function %s", functionName)

	sess, err := terraws.NewAuthenticatedSession(awsRegion)
	if err != nil {
		return nil, err
	}

	lambdaClient := lambda.New(sess)

	input := lambda.InvokeInput{
		FunctionName:   aws.String(functionName),
		Payload:        payload,
		InvocationType: aws.String(invocationType),
	}

	output, err := lambdaClient.Invoke(&input)
	if err != nil {
		return nil, err
	}

	return output.Payload, nil
}
