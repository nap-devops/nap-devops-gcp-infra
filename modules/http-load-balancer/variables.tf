# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to create the resources in."
  type        = string
}

variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
}

variable "prefix" {
  description = "Name prefix"
  type        = string
}

variable "isg_prefix" {
  description = "Instance group prefix"
  type        = string
}

variable "instances_regions" {
  description = "List of GCE instance region"
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------
variable "enable_ssl" {
  description = "Set to true to enable ssl. If set to 'true', you will also have to provide 'var.ssl_certificates'."
  type        = bool
  default     = true
}

variable "enable_http" {
  description = "Set to true to enable plain http. Note that disabling http does not force SSL and/or redirect HTTP traffic. See https://issuetracker.google.com/issues/35904733"
  type        = bool
  default     = false
}

variable "is_tcp_healthcheck" {
  description = "How health check work"
  type        = bool
  default     = false
}

variable "create_dns_entries" {
  description = "If set to true, create a DNS A Record in Cloud DNS for each domain specified in 'custom_domain_names'."
  type        = bool
  default     = false
}

variable "custom_domain_names" {
  description = "List of custom domain names."
  type        = list(string)
  default     = []
}

variable "dns_managed_zone_name" {
  description = "The name of the Cloud DNS Managed Zone in which to create the DNS A Records specified in 'var.custom_domain_names'. Only used if 'var.create_dns_entries' is true."
  type        = string
  default     = "replace-me"
}

variable "dns_record_ttl" {
  description = "The time-to-live for the site A records (seconds)"
  type        = number
  default     = 300
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the resources. The key is the label name and the value is the label value."
  type        = map(string)
  default     = {}
}

variable "health_check_port" {
  description = "Health check port"
  type        = string
  default     = "80"
}

variable "backend_port_name" {
  description = "Port to match instance group port-name"
  type        = string
  default     = "http"
}