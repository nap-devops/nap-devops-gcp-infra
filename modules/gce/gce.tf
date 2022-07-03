locals {
  tokens = split("-", var.vm_zone)
  region = "${local.tokens[0]}-${local.tokens[1]}"
}

resource "google_compute_disk" "gce-ext-disk" {
  name  = "${var.vm_name}-${var.vm_sequence}-data"
  # Need to restart the GCE or 'sudo resize2fs /dev/sdb' to make new size visible
  # See https://cloud.google.com/compute/docs/disks/resize-persistent-disk#gcloud
  type  = "pd-standard"
  zone  = var.vm_zone
  physical_block_size_bytes = 4096
  size = var.vm_ext_disk_size
}

module "gce" {
  source          = "git::https://github.com/its-software-services-devops/tf-module-gcp-vm.git//modules?ref=1.0.15"
  compute_name    = var.vm_name
  compute_seq     = var.vm_sequence
  vm_tags         = var.vm_tags
  vm_service_account = var.vm_service_account
  boot_disk_image  = var.boot_disk_image
  public_key_file  = "public-key/id_rsa.pub"
  vm_machine_type  = var.vm_machine_type
  vm_machine_zone  = var.vm_zone
  vm_deletion_protection = false
  startup_script_local_path = var.startup_script_path
  ssh_user         = var.vm_user
  create_nat_ip    = false
  user_data_path   = "scripts/cloud-init.yaml"
  external_disks   = [{index = 1, source = google_compute_disk.gce-ext-disk.id, mode = "READ_WRITE"}]
  network_configs  = [{index = 1, network = var.vm_subnet, nat_ip = ""}]
}


# Added auto snapshot here

resource "google_compute_disk_resource_policy_attachment" "attachment-001" {
  name = google_compute_resource_policy.snapshot-policy-001.name
  disk = "${var.vm_name}-${var.vm_sequence}-data"
  zone = var.vm_zone

  depends_on = [
    google_compute_disk.gce-ext-disk
  ]  
}

resource "google_compute_resource_policy" "snapshot-policy-001" {
  name = "${var.vm_name}-${var.vm_sequence}-data"
  region = local.region
  snapshot_schedule_policy {
    schedule {
      hourly_schedule {
        hours_in_cycle = 6
        start_time = "00:00"
      }
    }

    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
  }
}

# Boot disk
resource "google_compute_disk_resource_policy_attachment" "attachment-boot" {
  name = google_compute_resource_policy.snapshot-policy-boot.name
  disk = "${var.vm_name}-${var.vm_sequence}" #boot/local disk
  zone = var.vm_zone

  depends_on = [
    module.gce
  ]  
}

resource "google_compute_resource_policy" "snapshot-policy-boot" {
  name = "${var.vm_name}-${var.vm_sequence}-boot"
  region = local.region
  snapshot_schedule_policy {
    schedule {
      hourly_schedule {
        hours_in_cycle = 6
        start_time = "00:00"
      }
    }

    retention_policy {
      max_retention_days    = 7
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }
  }
}
