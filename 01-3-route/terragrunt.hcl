dependency "01-0-vpc" {
  config_path = "../01-0-vpc"
  skip_outputs = true
}

include "root" {
  path = find_in_parent_folders()
}
