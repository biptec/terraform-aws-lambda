package test

import (
	"encoding/json"
	"path/filepath"
	"strings"
	"testing"

	"github.com/biptec/terratest/modules/logger"
	"github.com/biptec/terratest/modules/shell"
	"github.com/biptec/terratest/modules/terraform"
	test_structure "github.com/biptec/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestLambdaBuild(t *testing.T) {
	t.Parallel()

	// Uncomment the items below to skip certain parts of the test
	// os.Setenv("SKIP_build", "true")
	// os.Setenv("SKIP_setup", "true")
	// os.Setenv("SKIP_apply", "true")
	// os.Setenv("SKIP_validate", "true")
	// os.Setenv("SKIP_perpetual_diff", "true")
	// os.Setenv("SKIP_destroy", "true")

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "examples/lambda-build")
	workingDir := filepath.Join("..", "stages", t.Name())

	test_structure.RunTestStage(t, "build", func() {
		buildDeploymentPackage(t, testFolder)
	})

	test_structure.RunTestStage(t, "setup", func() {
		terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, testFolder)
		test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)
		test_structure.SaveString(t, workingDir, "region", awsRegion)
	})

	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)
	awsRegion := test_structure.LoadString(t, workingDir, "region")

	defer test_structure.RunTestStage(t, "destroy", func() {
		terraform.Destroy(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "apply", func() {
		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "verify", func() {
		functionName := terraform.OutputRequired(t, terraformOptions, "function_name")
		requestPayload := createPayloadFormLambdaBuildFunction(t)

		responsePayload := triggerLambdaFunction(t, functionName, requestPayload, awsRegion)
		assertValidResponsePayload(t, []byte(responsePayload))
	})

	test_structure.RunTestStage(t, "perpetual_diff", func() {
		// Verify perpetual diff issue https://github.com/gruntwork-io/package-lambda/issues/26
		exitCode := terraform.PlanExitCode(t, terraformOptions)
		assert.Equal(t, exitCode, 0)
	})
}

func TestLambdaBuildCreateResourcesFalse(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "examples/lambda-build")
	terraformOptions, _, _ := createBaseTerraformOptions(t, testFolder)
	terraformOptions.Vars["create_resources"] = false
	planOut := terraform.InitAndPlan(t, terraformOptions)
	resourceCounts := terraform.GetResourceCount(t, planOut)
	assert.Equal(t, resourceCounts.Add, 0)
	assert.Equal(t, resourceCounts.Change, 0)
	assert.Equal(t, resourceCounts.Destroy, 0)
}

func buildDeploymentPackage(t *testing.T, testFolder string) {
	logger.Logf(t, "Building deployment package for lambda-build example")
	cmd := shell.Command{Command: filepath.Join(testFolder, "python/build.sh")}
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
