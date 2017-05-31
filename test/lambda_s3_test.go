package test

import (
	"testing"
	"github.com/gruntwork-io/terratest"
	"github.com/aws/aws-sdk-go/service/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/defaults"
	"encoding/json"
	terralog "github.com/gruntwork-io/terratest/log"
	"log"
)

func TestLambdaS3(t *testing.T) {
	t.Parallel()

	testName := "TestLambdaS3"
	logger := terralog.NewLogger(testName)

	resourceCollection := createBaseRandomResourceCollection(t)
	terratestOptions := createBaseTerratestOptions(testName, "../examples/lambda-s3", resourceCollection)
	defer terratest.Destroy(terratestOptions, resourceCollection)

	if _, err := terratest.Apply(terratestOptions); err != nil {
		t.Fatalf("Failed to apply templates in %s due to error: %s\n", terratestOptions.TemplatePath, err.Error())
	}

	functionName := getRequiredOutput(t, "function_name", terratestOptions)
	requestPayload := createEventObjectPayloadForLambdaFunction(t, terratestOptions, resourceCollection, logger)

	responsePayload := triggerLambdaFunction(t, functionName, requestPayload, resourceCollection, logger)
	actualBase64Data := getBase64ImageDataFromResponsePayload(t, responsePayload, logger)
	expectedBase64Data := readFileAsString(t, "gruntwork-logo.base64.txt")

	if expectedBase64Data == actualBase64Data {
		logger.Printf("Got back expected base 64 data from the lambda function!\n%s", actualBase64Data)
	} else {
		t.Fatalf("Did not get back expected base64 data. Expected:\n%s\nActual:\n%s", expectedBase64Data, actualBase64Data)
	}
}

func getBase64ImageDataFromResponsePayload(t *testing.T, payload []byte, logger *log.Logger) string {
	logger.Printf("Parsing response payload from Lambda function to extract base64-encoded image data.")

	response := map[string]string{}
	if err := json.Unmarshal(payload, &response); err != nil {
		t.Fatalf("Failed to unmarshal response payload from lambda function as map: %v", err)
	}

	base64Data, hasBase64Data := response["image_base64"]
	if !hasBase64Data {
		t.Fatalf("Response payload did not contain base 64 image data! %v", response)
	}

	return base64Data
}

func createEventObjectPayloadForLambdaFunction(t *testing.T, terratestOptions *terratest.TerratestOptions, resourceCollection *terratest.RandomResourceCollection, logger *log.Logger) []byte {
	s3BucketName := getRequiredOutput(t, "s3_bucket_name", terratestOptions)
	imageFileName := getRequiredOutput(t, "image_filename", terratestOptions)

	event := map[string]string{
		"aws_region": resourceCollection.AwsRegion,
		"s3_bucket": s3BucketName,
		"image_filename": imageFileName,
	}

	logger.Printf("Using event object %v as request payload to Lambda function.", event)

	out, err := json.Marshal(event)
	if err != nil {
		t.Fatalf("Failed to convert event object %v to JSON: %v", event, err)
	}

	return out
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