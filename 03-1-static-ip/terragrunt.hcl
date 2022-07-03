dependency "03-dns" {
  config_path = "../03-dns"
  skip_outputs = true
}

include "root" {
  path = find_in_parent_folders()
}
