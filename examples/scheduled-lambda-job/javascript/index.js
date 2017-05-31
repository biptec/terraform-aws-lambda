'use strict';

console.log('Loading function');

var SUCCESS_TEXT = "lambda-job-example completed successfully";

exports.handler = function(event, context, callback) {
  console.log('lambda-job-example received an event:', JSON.stringify(event, null, 2));
  console.log(SUCCESS_TEXT);
  callback(null, SUCCESS_TEXT);
};