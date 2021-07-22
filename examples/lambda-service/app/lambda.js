// @vendia/serverless-express is a handy library that lets you run a full Express web app, with all its route handling
// abilities, within a Lambda function. This way, you can have the API Gateway module send all traffic to this Lambda
// function, and instead of creating a Lambda "handler" function and trying to parse all the request details yourself,
// you use a normal web framework to do it for you.
const serverlessExpress = require('@vendia/serverless-express');

const app = require('./app');
exports.handler = serverlessExpress({ app })
