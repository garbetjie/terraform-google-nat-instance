resource random_id instance_suffix {
  byte_length = 2
  keepers = {
    zone = var.zone
    address = var.address
    startup_script = local.startup_script
    machine_type = var.machine_type
    disk_size = var.disk_size
    disk_type = var.disk_type
  }
}

resource random_id address_suffix {
  byte_length = 2
  keepers = {
    region = local.region
  }
}

resource google_compute_address address {
  name = "nat-instance-${local.region}-${random_id.address_suffix.hex}"
  address_type = "INTERNAL"
  region = local.region

  lifecycle {
    create_before_destroy = true
  }
}

resource google_compute_instance instance {
  name = "nat-instance-${local.region}-${random_id.instance_suffix.hex}"
  zone = var.zone
  can_ip_forward = true
  machine_type = random_id.instance_suffix.keepers.machine_type
  metadata_startup_script = random_id.instance_suffix.keepers.startup_script

  boot_disk {
    initialize_params {
      size = random_id.instance_suffix.keepers.disk_size
      type = random_id.instance_suffix.keepers.disk_type
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    network_ip = google_compute_address.address.address
    access_config {
      nat_ip = random_id.instance_suffix.keepers.address
    }
  }
}

resource null_resource delay_between_instance_and_route {
  provisioner "local-exec" {
    command = "sleep 10"
  }

  triggers = {
    after = google_compute_instance.instance.id
  }
}

resource google_compute_route route {
  name = google_compute_instance.instance.name
  network = "default"
  dest_range = "0.0.0.0/0"
  tags = ["requires-nat-${local.region}"]
  priority = 900
  next_hop_ip = google_compute_address.address.address
  depends_on = [null_resource.delay_between_instance_and_route]
}
