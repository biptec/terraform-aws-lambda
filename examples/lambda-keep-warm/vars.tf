# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

variable "name" {
  description = "The name used to namespace all the Lambda functions in this example."
  default     = "keep-warm-example"
}

variable "lambda_example_1_event" {
  description = "The event object to send to lambda_example_1 each time it's invoked by the keep-warm module."
  type        = "map"
  default     = {
    foo = "bar"
  }
}

variable "lambda_example_2_event" {
  description = "The event object to send to lambda_example_2 each time it's invoked by the keep-warm module."
  type        = "map"
  default     = {
    example = {
      a = 1
      b = 2
      c = 3
    }
  }
}

variable "schedule_expression" {
  description = "An expression that defines how often to the keep-warm module should invoke the example Lambda functions. For example, cron(0 20 * * ? *) or rate(5 minutes)."
  default     = "rate(5 minutes)"
}

variable "concurrency" {
  description = "How many concurrent requests the keep-warm module should make to each example Lambda function. With Lambda, each concurrent requests to the same function spins up a new container that must be kept warm, so you'll want to set this number to roughly the expected concurrency you see in real-world usage."
  default     = 1
}