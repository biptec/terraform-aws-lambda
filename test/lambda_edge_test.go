package test

import (
	"github.com/gruntwork-io/terratest"
	"testing"
	terralog "github.com/gruntwork-io/terratest/log"
	"encoding/json"
	"fmt"
	"github.com/stretchr/testify/assert"
)

func TestLambdaEdge(t *testing.T) {
	t.Parallel()

	testName := "TestLambdaEdge"
	logger := terralog.NewLogger(testName)

	resourceCollection := createBaseRandomResourceCollection(t)
	terratestOptions := createBaseTerratestOptions(testName, "../examples/lambda-edge", resourceCollection)
	defer terratest.Destroy(terratestOptions, resourceCollection)

	if _, err := terratest.Apply(terratestOptions); err != nil {
		t.Fatalf("Failed to apply templates in %s due to error: %s\n", terratestOptions.TemplatePath, err.Error())
	}

	functionName := getRequiredOutput(t, "function_name", terratestOptions)
	requestPayload := []byte(mockCloudfrontTriggerEvent)

	responsePayload := triggerLambdaFunction(t, functionName, requestPayload, resourceCollection, logger)
	assertValidLambdaEdgeResponsePayload(t, responsePayload)
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

const mockCloudfrontRequest =
`{
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