package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestLambdaVpc(t *testing.T) {
	t.Parallel()

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "/examples/lambda-vpc")

	terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	terraformOptions.Vars["vpc_name"] = fmt.Sprintf("lambda-vpc-example-%s", random.UniqueId())

	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.OutputRequired(t, terraformOptions, "function_name")

	response := triggerLambdaFunction(t, functionName, []byte{}, awsRegion)

	logger.Logf(t, "Got response from lambda function:\n%s", response)

	if !strings.Contains(response, "Example Domain") {
		t.Fatal("Response did not contain expected text 'Example Domain'")
	}
}
