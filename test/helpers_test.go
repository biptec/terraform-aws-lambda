package test

import (
	"github.com/gruntwork-io/terratest"
	"testing"
	"fmt"
	"io/ioutil"
	"github.com/aws/aws-sdk-go/service/lambda"
	"log"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/defaults"
)

func createBaseRandomResourceCollection(t *testing.T) *terratest.RandomResourceCollection {
	resourceCollectionOptions := terratest.NewRandomResourceCollectionOptions()

	// Explicitly forbid regions where Lambda is not available.
	resourceCollectionOptions.ForbiddenRegions = []string{
		"us-west-1",
		"sa-east-1",
		"ap-southeast-1",
		"ap-south-1",
		"ca-central-1", // Has lambda, but is incredibly slow, so tests often time out
	}

	randomResourceCollection, err := terratest.CreateRandomResourceCollection(resourceCollectionOptions)
	if err != nil {
		t.Fatalf("Failed to create random resource collection: %s\n", err.Error())
	}

	return randomResourceCollection
}

func createBaseTerratestOptions(testName string, templatePath string, randomResourceCollection *terratest.RandomResourceCollection) *terratest.TerratestOptions {
	terratestOptions := terratest.NewTerratestOptions()

	terratestOptions.UniqueId = randomResourceCollection.UniqueId
	terratestOptions.TemplatePath = templatePath
	terratestOptions.TestName = testName

	terratestOptions.Vars = map[string]interface{} {
		"aws_region": randomResourceCollection.AwsRegion,
		"name": fmt.Sprintf("%s-%s", testName, randomResourceCollection.UniqueId),
	}

	return terratestOptions
}

func getRequiredOutput(t *testing.T, outputName string, terratestOptions *terratest.TerratestOptions) string {
	output, err := terratest.Output(terratestOptions, outputName)
	if err != nil {
		t.Fatalf("Failed to get output %s: %v", outputName, err)
	}
	if output == "" {
		t.Fatalf("Got an empty string for required output %s", outputName)
	}
	return output
}

func readFileAsString(t *testing.T, filePath string) string {
	out, err := ioutil.ReadFile(filePath)
	if err != nil {
		t.Fatalf("Failed to read file %s: %v", filePath, err)
	}
	return string(out)
}

func triggerLambdaFunction(t *testing.T, functionName string, payload []byte, resourceCollection *terratest.RandomResourceCollection, logger *log.Logger) []byte {
	logger.Printf("Invoking lambda function %s", functionName)

	lambdaClient := lambda.New(session.New(), createAwsConfig(t, resourceCollection))

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

func createAwsConfig(t *testing.T, resourceCollection *terratest.RandomResourceCollection) *aws.Config {
	config := defaults.Get().Config.WithRegion(resourceCollection.AwsRegion)

	_, err := config.Credentials.Get()
	if err != nil {
		t.Fatalf("Error finding AWS credentials (did you set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables?). Underlying error: %v", err)
	}

	return config
}