# ------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator when calling this
# terraform module.
# ------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
}

variable "name" {
  description = "The name of the service. This is used to namespace all resources created by this module."
  type        = string
}

variable "domain_name" {
  description = "Full domain (e.g., api.example.com) you wish to bind to the API Gateway endpoint. Set to null if you do not wish to bind any domain name."
  type        = string
  default     = null
}

variable "hosted_zone_id" {
  description = "ID of the Route 53 zone where the domain should be configured. If null, this module will lookup the hosted zone using the domain name, or the provided parameters."
  type        = string
  default     = null
}

variable "hosted_zone_tags" {
  description = "Tags to use when looking up the Route 53 hosted zone to bind the domain to. Only used if hosted_zone_id is null."
  type        = map(string)
  default     = {}
}

variable "hosted_zone_domain_name" {
  description = "Domain name to use when looking up the Route 53 hosted zone to bind the API Gateway domain to. Only used if hosted_zone_id is null."
  type        = string
  default     = null
}

variable "certificate_domain" {
  description = "The domain to use when looking up the ACM certificate. This is useful for looking up wild card certificates that will match the given domain name."
  type        = string
  default     = null
}
