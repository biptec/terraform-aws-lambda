# ---------------------------------------------------------------------------------------------------------------------
# LOCALS USED THROUGHOUT MODULE
# ---------------------------------------------------------------------------------------------------------------------

locals {
  proxy_from_root     = var.path_prefix == ""
  enable_subpath_root = local.proxy_from_root == false
  enable_subpath      = var.root_only == false
}

# ---------------------------------------------------------------------------------------------------------------------
# PROXY THE ROOT URL (/)
# This is only configured if the path_prefix is ""
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "root" {
  count         = local.proxy_from_root ? 1 : 0
  rest_api_id   = var.api_gateway_rest_api.id
  resource_id   = var.api_gateway_rest_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_lambda" {
  count       = local.proxy_from_root ? 1 : 0
  rest_api_id = var.api_gateway_rest_api.id
  resource_id = var.api_gateway_rest_api.root_resource_id
  http_method = aws_api_gateway_method.root[0].http_method
  type        = "AWS_PROXY"

  # You can only invoke Lambdas with a POST
  integration_http_method = "POST"
  uri                     = data.aws_lambda_function.function.invoke_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# PROXY PATH_PREFIX ROOT IF PATH_PREFIX IS SET
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "path_prefix_root" {
  count       = local.enable_subpath && local.enable_subpath_root ? 1 : 0
  rest_api_id = var.api_gateway_rest_api.id
  parent_id   = var.api_gateway_rest_api.root_resource_id
  path_part   = var.path_prefix
}

resource "aws_api_gateway_method" "path_prefix_root" {
  count         = local.enable_subpath && local.enable_subpath_root ? 1 : 0
  rest_api_id   = var.api_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.path_prefix_root[0].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "path_prefix_root_lambda" {
  count       = local.enable_subpath && local.enable_subpath_root ? 1 : 0
  rest_api_id = var.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.path_prefix_root[0].id
  http_method = aws_api_gateway_method.path_prefix_root[0].http_method
  type        = "AWS_PROXY"

  # You can only invoke Lambdas with a POST
  integration_http_method = "POST"
  uri                     = data.aws_lambda_function.function.invoke_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# PROXY ALL NESTED URLS UNDER ROOT OR PATH_PREFIX
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "proxy" {
  count       = local.enable_subpath ? 1 : 0
  rest_api_id = var.api_gateway_rest_api.id
  parent_id   = local.proxy_from_root ? var.api_gateway_rest_api.root_resource_id : aws_api_gateway_resource.path_prefix_root[0].id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  count         = local.enable_subpath ? 1 : 0
  rest_api_id   = var.api_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.proxy[0].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_lambda" {
  count       = local.enable_subpath ? 1 : 0
  rest_api_id = var.api_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.proxy[0].id
  http_method = aws_api_gateway_method.proxy[0].http_method
  type        = "AWS_PROXY"

  # You can only invoke Lambdas with a POST
  integration_http_method = "POST"
  uri                     = data.aws_lambda_function.function.invoke_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE API GATEWAY PERMISSIONS TO INVOKE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_permission" "allow_api_gateway" {
  depends_on = [aws_api_gateway_resource.proxy]

  function_name = var.lambda_function_name
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_rest_api.execution_arn}/*/*/*"
}

# ---------------------------------------------------------------------------------------------------------------------
# LOOKUP LAMBDA FUNCTION BY NAME
# ---------------------------------------------------------------------------------------------------------------------

data "aws_lambda_function" "function" {
  function_name = var.lambda_function_name
}
