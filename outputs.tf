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
