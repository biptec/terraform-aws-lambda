package test

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestLambdaEdge(t *testing.T) {
	t.Parallel()

	terraformOptions, awsRegion, _ := createBaseTerraformOptions(t, "../examples/lambda-edge")
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.OutputRequired(t, terraformOptions, "function_name")
	requestPayload := []byte(mockCloudfrontTriggerEvent)

	responsePayload := triggerLambdaFunction(t, functionName, requestPayload, awsRegion)
	assertValidLambdaEdgeResponsePayload(t, []byte(responsePayload))

	// Verify perpetual diff issue https://github.com/gruntwork-io/package-lambda/issues/26
	exitCode := terraform.PlanExitCode(t, terraformOptions)
	assert.Equal(t, exitCode, 0)
}

func assertValidLambdaEdgeResponsePayload(t *testing.T, payload []byte) {
	expectedResponse := map[string]interface{}{}
	if err := json.Unmarshal([]byte(mockCloudfrontRequest), &expectedResponse); err != nil {
		t.Fatalf("Failed to unmarshal mock request as map: %v", err)
	}

	actualResponse := map[string]interface{}{}
	if err := json.Unmarshal(payload, &actualResponse); err != nil {
		t.Fatalf("Failed to unmarshal response payload from lambda function as map: %v", err)
	}

	assert.Equal(t, expectedResponse, actualResponse)
}

const mockCloudfrontRequest = `{
  "clientIp": "2001:0db8:85a3:0:0:8a2e:0370:7334",
  "querystring": "size=large",
  "uri": "/picture.jpg",
  "method": "GET",
  "headers": {
	"host": [
	  {
		"key": "Host",
		"value": "d111111abcdef8.cloudfront.net"
	  }
	],
	"user-agent": [
	  {
		"key": "User-Agent",
		"value": "curl/7.51.0"
	  }
	]
  },
  "origin": {
	"custom": {
	  "customHeaders": {
		"my-origin-custom-header": [
		  {
			"key": "My-Origin-Custom-Header",
			"value": "Test"
		  }
		]
	  },
	  "domainName": "example.com",
	  "keepaliveTimeout": 5,
	  "path": "/custom_path",
	  "port": 443,
	  "protocol": "https",
	  "readTimeout": 5,
	  "sslProtocols": [
		"TLSv1",
		"TLSv1.1"
	  ]
	},
	"s3": {
	  "authMethod": "origin-access-identity",
	  "customHeaders": {
		"my-origin-custom-header": [
		  {
			"key": "My-Origin-Custom-Header",
			"value": "Test"
		  }
		]
	  },
	  "domainName": "my-bucket.s3.amazonaws.com",
	  "path": "/s3_path",
	  "region": "us-east-1"
	}
  }
}`

var mockCloudfrontTriggerEvent = fmt.Sprintf(
	`{
  "Records": [
    {
      "cf": {
        "config": {
          "distributionId": "EDFDVBD6EXAMPLE",
          "requestId": "MRVMF7KydIvxMWfJIglgwHQwZsbG2IhRJ07sn9AkKUFSHS9EXAMPLE=="
        },
        "request": %s
      }
    }
  ]
}`, mockCloudfrontRequest)
