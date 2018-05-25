'use strict';

// The main entrypoint for this Lambda function. All it does is log the event object.
exports.handler = (event, context, callback) => {
  console.log(`Lambda function called with event: ${JSON.stringify(event)}`);
  callback(null, 'success');
};