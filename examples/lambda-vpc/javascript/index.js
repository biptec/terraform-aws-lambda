'use strict';

var http = require('http');

exports.handler = function(event, context, callback) {
  console.log('lambda-vpc-example received an event:', JSON.stringify(event, null, 2));

  // Make an HTTP call to check the security group has been configured properly, allowing this lambda function to
  // make outbound requests
  console.log('Making HTTP call to example.com');
  http.get({host: 'www.example.com', path: '/'}, function(resp){
    var str = '';

    resp.on('data', function(chunk){
      console.log('Got data: ' + chunk);
      str += chunk;
    });

    resp.on('end', function() {
      console.log('Got response: ' + str);
      callback(null, {response: str});
    });

  }).on("error", function(e){
    console.log('Got error: ' + e);
    callback(e);
  });
};