dependency "01-2-subnet" {
  config_path = "../01-2-subnet"
  skip_outputs = true
}

dependency "02-firewall" {
  config_path = "../02-firewall"
  skip_outputs = true
}

include "root" {
  path = find_in_parent_folders()
}

generate "provider" {
  path = "provider-gke.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {
  backend "gcs" {}
  required_providers {
    google = "4.20.0"
  }  
}
EOF
}
