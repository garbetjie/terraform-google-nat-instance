locals {
  network_tags = length(var.network_tags) == 0 ? ["requires-nat-${local.region}"] : var.network_tags

  region = join("-", slice(split("-", var.zone), 0, 2))

  socks_proxy = {
    enabled = var.socks_proxy.enabled
    port = coalesce(var.socks_proxy.port, 8888)
    debug = coalesce(var.socks_proxy.debug, 0),
    allowed_ranges = coalesce(var.socks_proxy.allowed_ranges, toset([]))
  }

  startup_script = file("${path.module}/startup_script.sh")

  instance_name = "nat-instance-${local.region}-${random_id.instance_suffix.hex}"

  instance_metadata = {
    startup-script-iptables-sh = file("${path.module}/startup_script_iptables.sh")

    startup-script-sysctl-sh = (
      length(var.sysctl_config) > 0
        ? templatefile("${path.module}/startup_script_sysctl.sh", { conf = var.sysctl_config })
        : "#!/usr/bin/env bash\n\nexit 0"
    )

    startup-script-proxy-sh = (
      local.socks_proxy.enabled
        ? templatefile("${path.module}/startup_script_proxy.sh", {
            port = local.socks_proxy.port
            address = google_compute_address.address.address
            debug = local.socks_proxy.debug,
            allowed_ranges = local.socks_proxy.allowed_ranges
          })
        : "#!/usr/bin/env bash\n\nexit 0"
    )
  }
}