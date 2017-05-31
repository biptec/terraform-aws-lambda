# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONFIGURE AWS TO RUN A LAMBDA FUNCTION ON A RECURRING SCHEDULE
# This template configures AWS to run a Lambda function according to a schedule you specify. This is useful for 
# asynchronous tasks and background work, such as a backup job to periodically back up a server. 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "aws_cloudwatch_event_rule" "scheduled_lambda_job" {
  name = "${var.lambda_function_name}-scheduled-lambda-job"
  description = "Event that runs the lambda function ${var.lambda_function_name} on a periodic schedule"
  schedule_expression = "${var.schedule_expression}"
}

resource "aws_cloudwatch_event_target" "scheduled_lambda_job" {
  rule = "${aws_cloudwatch_event_rule.scheduled_lambda_job.name}"
  target_id = "${var.lambda_function_name}-scheduled-lambda-job-target"
  arn = "${var.lambda_function_arn}"
}

resource "aws_lambda_permission" "allow_execution_from_cloudwatch" {
  statement_id = "${var.lambda_function_name}-allow-execution-from-cloudwatch"
  action = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_arn}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.scheduled_lambda_job.arn}"
}
