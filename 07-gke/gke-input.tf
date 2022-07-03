variable "project" {
  type     = string
  nullable = false 
}

variable "vpc_name" {
  type     = string
  nullable = false 
}

variable "gke_min_node_count" {
  type     = string
  nullable = false 
}

variable "gke_max_node_count" {
  type     = string
  nullable = false 
}

variable "gke_node_count" {
  type     = string
  nullable = false 
}

variable "gke_machine_type" {
  type     = string
  nullable = false 
}
