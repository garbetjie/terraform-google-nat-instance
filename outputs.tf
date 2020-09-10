output address {
  value = google_compute_address.address.address
}

output nat_address {
  value = var.address
}

output instance_name {
  value = google_compute_instance.instance.name
}

output route_name {
  value = google_compute_route.route.name
}
