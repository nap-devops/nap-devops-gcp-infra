locals {
  q_params = var.params

  zones = [
      local.q_params[6] != "" ? "a" : "", 
      local.q_params[7] != "" ? "b" : "", 
      local.q_params[8] != "" ? "c" : ""
  ]

  zones_out = [for z in local.zones : z if z != ""]
}
