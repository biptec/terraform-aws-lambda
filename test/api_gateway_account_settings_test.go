package test

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestApiGatewayAccountSettings(t *testing.T) {

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "examples")
	testBasePath := filepath.Join(testFolder, "api-gateway-account-settings")

	terratestOptions, awsRegion, uniqueID := createBaseTerraformOptions(t, testBasePath)
	defer terraform.Destroy(t, terratestOptions)

	terratestOptions.Vars = map[string]interface{}{
		"aws_region":    awsRegion,
		"iam_role_name": t.Name() + uniqueID + "_iam_role_name",
	}
	terraform.InitAndApply(t, terratestOptions)

	iamRoleArn := terraform.Output(t, terratestOptions, "iam_role_arn")
	assert.NotEmpty(t, iamRoleArn)

	iamRoleName := terraform.Output(t, terratestOptions, "iam_role_name")
	assert.NotEmpty(t, iamRoleName)
}
