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

func triggerLambdaFunction(t *testing.T, functionName string, payload []byte, awsRegion string) []byte {
	logger.Logf(t, "Invoking lambda function %s", functionName)

	sess, err := terraws.NewAuthenticatedSession(awsRegion)
	if err != nil {
		t.Fatal(err)
	}

	lambdaClient := lambda.New(sess)

	input := lambda.InvokeInput{
		FunctionName: aws.String(functionName),
		Payload: payload,
	}

	output, err := lambdaClient.Invoke(&input)
	if err != nil {
		t.Fatal(err)
	}

	return output.Payload
}
