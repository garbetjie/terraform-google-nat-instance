output address {
  value = google_compute_address.address.address
  description = "Internal IP address of this NAT instance."
}

output nat_address {
  value = var.address
  description = "NAT IP address of this NAT instance."
}

output instance_name {
  value = google_compute_instance.instance.name
  description = "Name of the Compute Engine instance."
}

output route_name {
  value = google_compute_route.route.name
  description = "Name of the route used to route traffic through the instance."
}

output route_priority {
  value = google_compute_route.route.priority
  description = "Priority assigned to the networking route used to route traffic through this instance."
}

output zone {
  value = var.zone
  description = "Zone in which the Compute Engine instance has been placed."
}

output machine_type {
  value = google_compute_instance.instance.machine_type
  description = "Machine type of the instance."
}

output disk_size {
  value = google_compute_instance.instance.boot_disk[0].initialize_params[0].size
  description = "Size of the instance's disk (in GB)."
}

output disk_type {
  value = google_compute_instance.instance.boot_disk[0].initialize_params[0].type
  description = "Type of the instance's disk."
}

output wait_duration {
  value = var.wait_duration
  description = "The duration (in seconds) that was allowed for the NAT instance to finish booting."
}

output network_tags {
  value = google_compute_route.route.tags
  description = "Tags to which this instance's route applies."
}

output sysctl_config {
  value = var.sysctl_config
  description = "sysctl config applied on NAT instance boot."
}

output socks_proxy {
  value = local.socks_proxy
  description = "SOCKS proxy config applied."
}