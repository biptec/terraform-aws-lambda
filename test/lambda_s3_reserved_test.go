package test

import (
	"testing"
)

func TestLambdaS3Reserved(t *testing.T) {
	reservedConcurrentExecutions := 1
	LambdaS3Test(t, &reservedConcurrentExecutions)
}
