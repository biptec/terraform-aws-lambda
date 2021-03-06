package test

import (
	"encoding/json"
	"fmt"
	"testing"

	terraws "github.com/biptec/terratest/modules/aws"
	"github.com/biptec/terratest/modules/logger"
	"github.com/biptec/terratest/modules/random"
	"github.com/biptec/terratest/modules/terraform"
	test_structure "github.com/biptec/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestLambdaDLQ(t *testing.T) {

	testFolder := test_structure.CopyTerraformFolderToTemp(t, "..", "/examples/lambda-dead-letter-queue")
	terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, testFolder)

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	checkSQSForMessages(t, terraformOptions, awsRegion)

}

func checkSQSForMessages(t *testing.T, terraformOptions *terraform.Options, awsRegion string) {
	functionName := terraform.OutputRequired(t, terraformOptions, "function_name")
	queueURL := terraform.OutputRequired(t, terraformOptions, "queue_url")
	timeoutSec := 180

	_, requestPayload := createEventPayloadForDLQLambdaFunction(t)

	triggerLambdaFunctionAsync(t, functionName, requestPayload, awsRegion)

	queueResponse := terraws.WaitForQueueMessage(t, awsRegion, queueURL, timeoutSec)
	logger.Logf(t, "SQS Message Response %v: ", queueResponse)
	assert.NoError(t, queueResponse.Error)
	assert.Equal(t, string(requestPayload), queueResponse.MessageBody)

}

func createEventPayloadForDLQLambdaFunction(t *testing.T) (map[string]string, []byte) {
	event := map[string]string{
		"text": fmt.Sprintf("test-%s", random.UniqueId()),
	}

	logger.Logf(t, "Using event object %v as request payload to Lambda function.", event)

	out, err := json.Marshal(event)
	require.NoError(t, err)

	return event, out
}
