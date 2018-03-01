'use strict';

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    console.log("Incoming request:", request);

    // Allows the request to be processed by CloudFront
    callback(null, request);
};
