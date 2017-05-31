package test

import (
	"github.com/gruntwork-io/terratest"
	"testing"
	"fmt"
	"io/ioutil"
)

func createBaseRandomResourceCollection(t *testing.T) *terratest.RandomResourceCollection {
	resourceCollectionOptions := terratest.NewRandomResourceCollectionOptions()

	// Explicitly forbid regions where Lambda is not available.
	resourceCollectionOptions.ForbiddenRegions = []string{
		"us-west-1",
		"sa-east-1",
		"ap-southeast-1",
		"ap-south-1",
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
