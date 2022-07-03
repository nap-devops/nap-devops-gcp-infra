variable "project" {
  type     = string
  nullable = false 
}

variable "region" {
  type     = string
  nullable = false 
}

variable "type" {
  type     = string
  nullable = false 
}

variable "zone_a_instances" {
  type     = list
  nullable = false 
}

variable "zone_b_instances" {
  type     = list
  nullable = false 
}

variable "zone_c_instances" {
  type     = list
  nullable = false 
}

variable "extra_ports" {
  type = list(object({
    name = string
    port = string
  }))
  default = []
}