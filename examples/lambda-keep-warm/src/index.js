'use strict';

// Generate a unique ID when this function starts so we can tell Lambda functions running in different containers apart
// from each other. This unique ID code is based on: https://stackoverflow.com/a/40191779/483528
const crypto = require('crypto');
const functionId = crypto.randomBytes(16).toString("hex");

let invocationCount = 0;

const sleepTimeMs = 3000;

// The main entrypoint for this Lambda function. All it does is log the event object, sleep for a little while (this
// is mainly useful at test time so we can verify the concurrency settings work as expected) and return an object with
// the function's unique ID and how many times it has been invoked.
exports.handler = (event, context, callback) => {
  console.log(`Event: ${JSON.stringify(event)}`);

  if (event.type !== 'test') {
    invocationCount++;
  }

  console.log(`Lambda function ${functionId} has been invoked ${invocationCount} times.`);

  console.log(`Sleeping for ${sleepTimeMs} ms before invoking callback function.`);
  setTimeout(() => callback(null, {functionId, invocationCount}), sleepTimeMs);
};