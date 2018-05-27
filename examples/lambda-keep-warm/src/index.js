'use strict';

const AWS = require('aws-sdk');

// Generate a unique ID when this function starts so we can tell Lambda functions running in different containers apart
// from each other. This unique ID code is based on: https://stackoverflow.com/a/40191779/483528
const crypto = require('crypto');
const functionId = crypto.randomBytes(16).toString("hex");

// Sleep this long before completing a request. This allows us to better control how many functions execute concurrently
// at test time.
const sleepTimeMs = 5000;

// The main entrypoint for this Lambda function. This function writes a new entry to a DynamoDB table so our automated
// tests can count how many times it was invoked.
exports.handler = (event, context, callback) => {
  console.log(`Lambda function ${functionId} got called with event: ${JSON.stringify(event)}`);

  const dynamodb = new AWS.DynamoDB({region: getRequiredEnvVar('AWS_REGION')});

  const params = {
    Item: {
      RequestId: {S: context.awsRequestId},
      FunctionId: {S: functionId},
      FunctionName: {S: context.functionName},
      Event: {S: JSON.stringify(event)}
    },
    TableName: getRequiredEnvVar('DYNAMODB_TABLE_NAME')
  };

  // Sleep for a bit to help better control concurrency in our automated tests
  console.log(`Sleeping for ${sleepTimeMs} ms and then writing to DynamoDB.`);
  setTimeout(() => dynamodb.putItem(params, callback), sleepTimeMs);
};

// Get the env var with the given name. Throw an exception if that env var is not set.
function getRequiredEnvVar(name) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Required environment variable ${name} is not set.`);
  }

  return value;
}