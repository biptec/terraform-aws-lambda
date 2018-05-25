'use strict';

const AWS = require('aws-sdk');

// The main entrypoint for this Lambda function. It loops over the Lambda function ARNs passed in as an environment
// variable and invokes them all with the specified event.
exports.handler = (event, context, callback) => {
  const awsRegion = getRequiredEnvVar('AWS_REGION');
  const concurrency = parseInt(getRequiredEnvVar('CONCURRENCY'));
  const functionToEventMap = JSON.parse(getRequiredEnvVar('FUNCTION_TO_EVENT_MAP'));
  const lambda = new AWS.Lambda({region: awsRegion});

  console.log(`Invoking ${Object.keys(functionToEventMap).length} Lambda functions with a concurrency of ${concurrency}`);

  const promises = Object.entries(functionToEventMap).reduce((acc, [functionArn, event]) => {
    return invokeFunction(functionArn, event, lambda, concurrency);
  }, []);

  Promise
      .all(promises)
      .then(_ => callback(null, "Success"))
      .catch(err => callback(err));
};

// Asynchronously invoke the given Lambda function concurrency times, passing it the given event each time. Returns
// the list of Promises for the asynchronous invocations.
function invokeFunction(functionArn, event, lambda, concurrency) {
  const params = {
    FunctionName: functionArn,
    InvocationType: 'Event',
    Payload: event,
  };

  console.log(`Invoking Lambda function ${functionArn} asynchronously ${concurrency} times.`);

  return Array(concurrency).fill().map(_ => lambda.invoke(params).promise());
}

// Get the env var with the given name. Throw an exception if that env var is not set.
function getRequiredEnvVar(name) {
  const value = process.env[name];

  if (!value) {
    throw new Error(`Required environment variable ${name} is not set.`);
  }

  return value;
}