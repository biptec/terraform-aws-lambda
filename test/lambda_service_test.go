package test

import (
	"fmt"
	"path/filepath"
	"strings"
	"testing"
	"time"

	http_helper "github.com/biptec/terratest/modules/http-helper"
	"github.com/biptec/terratest/modules/shell"
	"github.com/biptec/terratest/modules/terraform"
	test_structure "github.com/biptec/terratest/modules/test-structure"
)

const (
	testDomainName = "gruntwork.in"

	// It can take a minute or so for the lambda function and API gateway to converge
	lambdaServiceMaxRetries         = 30
	lambdaServiceTimeBetweenRetries = 5 * time.Second
)

var domainTags = map[string]interface{}{"original": "true"}

func TestLambdaService(t *testing.T) {
	t.Parallel()

	// Uncomment any of the following to skip that stage in the test
	//os.Setenv("SKIP_setup_app", "true")
	//os.Setenv("SKIP_setup", "true")
	//os.Setenv("SKIP_deploy", "true")
	//os.Setenv("SKIP_verify", "true")
	//os.Setenv("SKIP_destroy", "true")

	test_structure.RunTestStage(t, "setup_app", func() {
		// Make sure dependencies are installed
		cmd := shell.Command{
			Command:    "npm",
			Args:       []string{"install"},
			WorkingDir: "../examples/lambda-service/app",
		}
		shell.RunCommand(t, cmd)
	})

	t.Run("EdgeWithDomain", func(t *testing.T) {
		t.Parallel()
		testLambdaServiceRunner(t, "edge", true, func(url string) {
			// Verify that we get back a 200 OK with the expected response
			http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello", url), nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello/world", url), nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
		})
	})

	t.Run("EdgeWithoutDomain", func(t *testing.T) {
		t.Parallel()
		testLambdaServiceRunner(t, "edge", false, func(url string) {
			// Verify that we get back a 200 OK with the expected response
			http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello", url), nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello/world", url), nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
		})
	})

	t.Run("RegionalWithDomain", func(t *testing.T) {
		t.Parallel()
		testLambdaServiceRunner(t, "regional", true, func(url string) {
			// Verify that we get back a 200 OK with the expected response
			http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello", url), nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello/world", url), nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
		})
	})

	t.Run("RegionalWithoutDomain", func(t *testing.T) {
		t.Parallel()
		testLambdaServiceRunner(t, "regional", false, func(url string) {
			// Verify that we get back a 200 OK with the expected response
			http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello", url), nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello/world", url), nil, 200, "Hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
		})
	})

	t.Run("WithPathRouting", func(t *testing.T) {
		t.Parallel()
		testLambdaServiceRunner(t, "path-routing", false, func(url string) {
			// Verify that we get back a 200 OK with the expected response
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s", url), nil, 200, "hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/", url), nil, 200, "hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello", url), nil, 200, "hello", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello/world", url), nil, 200, "hello", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/world", url), nil, 200, "world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/world/hello", url), nil, 200, "world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)

			// Since the root function is not a catch all, other paths should not be routable.
			http_helper.HttpGetWithRetry(
				t,
				fmt.Sprintf("%s/api/v1", url),
				nil,
				// Default error message and error code for API Gateway endpoints that have no routes
				403, `{"message":"Missing Authentication Token"}`,
				lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries,
			)
		})
	})

	t.Run("WithPathRoutingCatchAll", func(t *testing.T) {
		t.Parallel()
		testLambdaServiceRunner(t, "path-routing-with-catchall", false, func(url string) {
			// Verify that we get back a 200 OK with the expected response
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s", url), nil, 200, "hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/api/v1", url), nil, 200, "hello world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello", url), nil, 200, "hello", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/hello/world", url), nil, 200, "hello", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/world", url), nil, 200, "world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
			http_helper.HttpGetWithRetry(t, fmt.Sprintf("%s/world/hello", url), nil, 200, "world", lambdaServiceMaxRetries, lambdaServiceTimeBetweenRetries)
		})
	})

}

func testLambdaServiceRunner(
	t *testing.T,
	moduleSubPath string,
	withDomain bool,
	validationFunc func(string),
) {
	workingDir := filepath.Join(".", "stages", t.Name()) // Create a directory path that won't conflict
	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", fmt.Sprintf("examples/lambda-service/%s", moduleSubPath))

	test_structure.RunTestStage(t, "setup", func() {
		options, _, uniqueID := createBaseTerraformOptions(t, testFolder)
		if withDomain {
			domain := fmt.Sprintf("%s.%s", strings.ToLower(uniqueID), testDomainName)
			options.Vars["domain_name"] = domain
			options.Vars["hosted_zone_tags"] = domainTags
			options.Vars["hosted_zone_domain_name"] = testDomainName
			options.Vars["certificate_domain"] = fmt.Sprintf("*.%s", testDomainName)
		}
		test_structure.SaveTerraformOptions(t, workingDir, options)
	})

	defer test_structure.RunTestStage(t, "destroy", func() {
		options := test_structure.LoadTerraformOptions(t, workingDir)
		terraform.Destroy(t, options)
	})
	test_structure.RunTestStage(t, "deploy", func() {
		options := test_structure.LoadTerraformOptions(t, workingDir)
		terraform.InitAndApply(t, options)
	})

	test_structure.RunTestStage(t, "verify", func() {
		options := test_structure.LoadTerraformOptions(t, workingDir)
		url := terraform.OutputRequired(t, options, "url")
		validationFunc(url)
	})
}
