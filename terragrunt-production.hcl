locals {
  project  = "nap-devops-prod"
  region = "asia-southeast1"
}

inputs = {
  project = local.project
  name_prefix = "nap-devops"
  vpc_name  = "nap-devops-vpc"
  top_level_domain = "devops.napbiotec.io"

  gke_min_node_count = "2"
  gke_max_node_count = "2"
  gke_node_count = "2"
  gke_machine_type = "e2-standard-4"
}

################################## Common ########################################

remote_state {
 backend = "gcs" 
 config = {
   bucket = "${local.project}-infra-tf-states"
   prefix = path_relative_to_include()
   project = "${local.project}"
   location = "${local.region}"
 }
}

generate "provider" {
  path = "provider.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
provider "google" {
  project     = "${local.project}"
  region      = "${local.region}"
}

terraform {
  backend "gcs" {}
  required_providers {
    google = "4.10.0"
  }  
}
EOF
}
