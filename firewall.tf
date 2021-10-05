resource google_compute_firewall socks_proxy {
  count = local.socks_proxy.enabled ? 1 : 0
  name = "${local.instance_name}-socks-proxy"
  network = google_compute_instance.instance.network_interface[0].network

  allow {
    protocol = "tcp"
    ports = [local.socks_proxy.port]
  }

  allow {
    protocol = "udp"
    ports = [local.socks_proxy.port]
  }

  target_tags = [local.instance_name]
  source_ranges = local.socks_proxy.allowed_ranges
}