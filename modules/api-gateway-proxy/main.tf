# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE API GATEWAY DEPLOYMENT
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# SET TERRAFORM REQUIREMENTS FOR RUNNING THIS MODULE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 1.1.x. However, to make upgrading easier, we are setting 1.0.0 as the minimum version.
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.58, < 4.0"
      # Edge API Gateway domains require ACM certs to be in us-east-1, so we need an aws provider alias that is
      # configured to the us-east-1 region when looking up an ACM cert for the domain.
      configuration_aliases = [aws.us_east_1]
    }
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN API GATEWAY TO PROXY REQUESTS TO THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "proxy" {
  name = var.api_name
  description = (
    var.api_description != ""
    ? var.api_description
    : "REST API that proxies to lambda functions ${local.all_lambda_functions}."
  )
  binary_media_types       = var.api_binary_media_types
  minimum_compression_size = var.api_minimum_compression_size
  api_key_source           = var.api_key_source
  tags                     = var.custom_tags

  # MAINTAINER'S NOTE: It may seem more intuitive to expose the variable as disable_execute_api_endpoint, but all our
  # modules use the pattern of "enable_*", so for a consistent interface, it makes more sense to use enable for user
  # input.
  disable_execute_api_endpoint = !var.enable_execute_api_endpoint

  dynamic "endpoint_configuration" {
    # The contents of the for_each list is irrelevant, as it is only used to turn this subblock on and off.
    for_each = var.api_endpoint_configuration != null ? ["once"] : []
    content {
      types            = [var.api_endpoint_configuration.type]
      vpc_endpoint_ids = var.api_endpoint_configuration.vpc_endpoint_ids
    }
  }
}

locals {
  all_lambda_functions = join(", ", [
    for path_prefix, lambda_function_name in var.lambda_functions :
    lambda_function_name
  ])
}


# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE PROXY METHODS
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_proxies" {
  for_each             = var.lambda_functions
  source               = "../api-gateway-proxy-methods"
  api_gateway_rest_api = aws_api_gateway_rest_api.proxy
  lambda_function_name = each.value
  path_prefix          = each.key
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE ROOT LAMBDA FUNCTION IF REQUESTED
# This configured routing only the root path (/) to the provided lambda function, and not the proxies.
# ---------------------------------------------------------------------------------------------------------------------

module "root_path_only" {
  count                = var.enable_root_lambda_function ? 1 : 0
  source               = "../api-gateway-proxy-methods"
  api_gateway_rest_api = aws_api_gateway_rest_api.proxy
  lambda_function_name = var.root_lambda_function_name
  path_prefix          = ""
  root_only            = true
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE API GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "proxy" {
  depends_on = [
    module.lambda_proxies,
    module.root_path_only,
  ]

  rest_api_id = aws_api_gateway_rest_api.proxy.id
  description = var.deployment_description

  triggers = merge(
    (
      # This exists because there is no reliable mechanism in terraform to tie a resource to changes in other resources.
      # See https://github.com/hashicorp/terraform/issues/8099 and https://github.com/hashicorp/terraform/issues/6613 for
      # more information.
      var.force_deployment
      ? {
        deployment_timestamp = timestamp()
      }
      : {}
    ),
    {
      deployment_id = var.deployment_id
    },
  )

  # Terraform docs for the resource recommends adding create_before_destroy to avoid errors such as BadRequestException:
  # Active stages pointing to this deployment must be moved or deleted on recreation.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.proxy.id
  deployment_id = aws_api_gateway_deployment.proxy.id
  stage_name    = var.stage_name
  description   = var.stage_description
}

resource "aws_api_gateway_method_settings" "all_paths" {
  for_each = var.api_settings

  rest_api_id = aws_api_gateway_rest_api.proxy.id
  stage_name  = aws_api_gateway_stage.proxy.stage_name
  method_path = "*/${each.key}"

  # NOTE: This must be updated each time the AWS provider adds additional supported settings.
  settings {
    metrics_enabled                            = lookup(each.value, "metrics_enabled", null)
    logging_level                              = lookup(each.value, "logging_level", null)
    data_trace_enabled                         = lookup(each.value, "data_trace_enabled", null)
    throttling_burst_limit                     = lookup(each.value, "throttling_burst_limit", null)
    throttling_rate_limit                      = lookup(each.value, "throttling_rate_limit", null)
    caching_enabled                            = lookup(each.value, "caching_enabled", null)
    cache_ttl_in_seconds                       = lookup(each.value, "cache_ttl_in_seconds", null)
    cache_data_encrypted                       = lookup(each.value, "cache_data_encrypted", null)
    require_authorization_for_cache_control    = lookup(each.value, "require_authorization_for_cache_control", null)
    unauthorized_cache_control_header_strategy = lookup(each.value, "unauthorized_cache_control_header_strategy", null)
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE ROUTE 53 DOMAIN IF REQUESTED
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_domain_name" "proxy" {
  count                    = local.enable_domain ? 1 : 0
  domain_name              = var.domain_name
  certificate_arn          = local.use_regional_domain ? null : local.us_east_1_certificate_arn
  regional_certificate_arn = local.use_regional_domain ? local.certificate_arn : null

  dynamic "endpoint_configuration" {
    # The contents of the for_each list is irrelevant, as it is only used to turn this subblock on and off.
    for_each = local.use_regional_domain ? ["once"] : []
    content {
      types = ["REGIONAL"]
    }
  }

}

resource "aws_route53_record" "proxy" {
  count   = local.enable_domain ? 1 : 0
  name    = length(aws_api_gateway_domain_name.proxy) > 0 ? aws_api_gateway_domain_name.proxy[0].domain_name : null
  zone_id = local.hosted_zone_id
  type    = "A"

  dynamic "alias" {
    # The contents of the for_each list is irrelevant, as it is only used to turn this subblock on and off.
    for_each = local.use_regional_domain == false ? ["once"] : []
    content {
      name                   = length(aws_api_gateway_domain_name.proxy) > 0 ? aws_api_gateway_domain_name.proxy[0].cloudfront_domain_name : null
      zone_id                = length(aws_api_gateway_domain_name.proxy) > 0 ? aws_api_gateway_domain_name.proxy[0].cloudfront_zone_id : null
      evaluate_target_health = true
    }
  }

  dynamic "alias" {
    # The contents of the for_each list is irrelevant, as it is only used to turn this subblock on and off.
    for_each = local.use_regional_domain ? ["once"] : []
    content {
      name                   = length(aws_api_gateway_domain_name.proxy) > 0 ? aws_api_gateway_domain_name.proxy[0].regional_domain_name : null
      zone_id                = length(aws_api_gateway_domain_name.proxy) > 0 ? aws_api_gateway_domain_name.proxy[0].regional_zone_id : null
      evaluate_target_health = true
    }
  }

}

resource "aws_api_gateway_base_path_mapping" "proxy" {
  count       = local.enable_domain ? 1 : 0
  api_id      = aws_api_gateway_rest_api.proxy.id
  stage_name  = aws_api_gateway_stage.proxy.stage_name
  domain_name = length(aws_api_gateway_domain_name.proxy) > 0 ? aws_api_gateway_domain_name.proxy[0].domain_name : null
  base_path   = var.domain_base_path
}

locals {
  enable_domain = var.domain_name != null
  use_regional_domain = (
    # Ideally this is implemented using &&, but terraform does not support short circuiting boolean operations so we
    # resort to a conditional
    var.api_endpoint_configuration != null
    ? var.api_endpoint_configuration.type != "EDGE"
    : false
  )
  certificate_arn           = length(data.aws_acm_certificate.issued) > 0 ? data.aws_acm_certificate.issued[0].arn : var.certificate_arn
  us_east_1_certificate_arn = length(data.aws_acm_certificate.issued_us_east_1) > 0 ? data.aws_acm_certificate.issued_us_east_1[0].arn : var.certificate_arn

  hosted_zone_id = (
    local.enable_domain
    ? (
      var.hosted_zone_id != null
      ? var.hosted_zone_id
      : data.aws_route53_zone.selected[0].zone_id
    )
    : null
  )
}


# The following routine looksup ACM Certificates. There are two data sources to account for the fact that when
# configuring an edge domain, you need to use an ACM cert that resides in us-east-1, while for regional endpoints you
# need the ACM cert for the region where you are configuring the domain.

data "aws_acm_certificate" "issued" {
  count       = local.enable_domain && var.certificate_arn == null && local.use_regional_domain ? 1 : 0
  domain      = var.certificate_domain == null ? var.domain_name : var.certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "issued_us_east_1" {
  count       = local.enable_domain && var.certificate_arn == null && local.use_regional_domain == false ? 1 : 0
  domain      = var.certificate_domain == null ? var.domain_name : var.certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
  provider    = aws.us_east_1
}

data "aws_route53_zone" "selected" {
  count = local.enable_domain && var.hosted_zone_id == null ? 1 : 0
  name  = var.hosted_zone_domain_name != null ? "${var.hosted_zone_domain_name}." : null
  tags  = var.hosted_zone_tags
}
