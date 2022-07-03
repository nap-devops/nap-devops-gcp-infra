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

variable "region" {
  description = "Region of LB"
  type        = string
}

variable "network" {
  description = "VPC network"
  type        = string
}

variable "is_tcp_healthcheck" {
  description = "How health check work"
  type        = bool
  default     = false
}

variable "subnetwork" {
  description = "VPC subnetwork"
  type        = string
}

variable "instances_zones" {
  description = "List of GCE instance zone, such as ['a', 'b', 'c']"
  type        = list(string)
  default     = []
}

variable "isg_prefix" {
  description = "Instance group prefix"
  type        = string
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
