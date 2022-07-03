locals {
  zone_a = "${var.region}-a"
  zone_b = "${var.region}-b"
  zone_c = "${var.region}-c"
}

resource "google_compute_instance_group" "group-a" {
  name      = "${var.type}-group-${local.zone_a}"
  zone      = "${local.zone_a}"
  description = "Created by Terraform - Do not modify manually!!!"

  # Not be able to update the group by adding the instance later, it might be a bug!!!
  # Workaround - we can manually add new GCE into group and make change to terraform code!!!
  # https://github.com/hashicorp/terraform-provider-google/issues/10797

  instances = [
    for s in var.zone_a_instances : "projects/${var.project}/zones/${local.zone_a}/instances/${var.type}-${local.zone_a}-${s}"
  ]

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }

  dynamic "named_port" {
    for_each = [for s in var.extra_ports  : { 
        name   = s.name
        port = s.port
    }]    
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group" "group-b" {
  name      = "${var.type}-group-${local.zone_b}"
  zone      = "${local.zone_b}"
  description = "Created by Terraform - Do not modify manually!!!"

  # Not be able to update the group by adding the instance later, it might be a bug!!!
  # Workaround - we can manually add new GCE into group and make change to terraform code!!!
  # https://github.com/hashicorp/terraform-provider-google/issues/10797

  instances = [
    for s in var.zone_b_instances : "projects/${var.project}/zones/${local.zone_b}/instances/${var.type}-${local.zone_b}-${s}"
  ]

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }

  dynamic "named_port" {
    for_each = [for s in var.extra_ports  : { 
        name   = s.name
        port = s.port
    }]    
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "google_compute_instance_group" "group-c" {
  name      = "${var.type}-group-${local.zone_c}"
  zone      = "${local.zone_c}"
  description = "Created by Terraform - Do not modify manually!!!"

  # Not be able to update the group by adding the instance later, it might be a bug!!!
  # Workaround - we can manually add new GCE into group and make change to terraform code!!!
  # https://github.com/hashicorp/terraform-provider-google/issues/10797

  instances = [
    for s in var.zone_c_instances : "projects/${var.project}/zones/${local.zone_c}/instances/${var.type}-${local.zone_c}-${s}"
  ]

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }

  dynamic "named_port" {
    for_each = [for s in var.extra_ports  : { 
        name   = s.name
        port = s.port
    }]    
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
