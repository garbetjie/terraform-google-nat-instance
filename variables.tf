variable address {
  type = string
  description = "External IP address to assign to this instance."
}

variable zone {
  type = string
  description = "Zone in which to place this instance. Must be the same region as the IP address provided."
}

variable machine_type {
  type = string
  default = "f1-micro"
  description = "Machine type of the instance."
}

variable disk_size {
  type = number
  default = 15
  description = "Size of the instance's disk (in GB)."
}

variable disk_type {
  type = string
  default = "pd-standard"
  description = "Type of the instance's disk (one of `pd-standard` or `pd-ssd`). `google` provider `>= 3.37` allows the option of `pd-balanced` to be provided."
}

variable sysctl_config {
  type = map(string)
  default = {}
  description = "sysctl configuration to apply on startup."
}

variable wait_duration {
  type = number
  default = 10
  description = "The duration (in seconds) to wait for the NAT instance to finish starting up."
}

variable route_priority {
  type = number
  default = 900
  description = "The priority to assign the networking route that routes traffic through this instance."
}

variable network_tags {
  type = list(string)
  default = null
  description = "Tags to which this route applies. Defaults to [\"requires-nat-$${local.region}\"]"
}

variable enable_http_proxy {
  type = bool
  default = false
  description = "Flag indicating whether to enable the NAT instance to act as an HTTP forward proxy."
}

variable http_proxy_port {
  type = number
  default = 8888
  description = "The port on which to bind the HTTP forward proxy."
}

variable http_proxy_max_connections {
  type = number
  default = 100
  description = "Maximum number of active connections to support through the HTTP forward proxy."
}

variable http_proxy_start_servers {
  type = number
  default = 10
  description = "Number of proxy processes to start."
}

variable http_proxy_min_spare_servers {
  type = number
  default = 5
  description = "When the number of spare proxy processes falls below this value, start up more processes."
}

variable http_proxy_max_spare_servers {
  type = number
  default = 20
  description = "When the number of spare proxy processes is above this value, kill off some processes."
}

variable http_proxy_connection_timeout {
  type = number
  default = 600
  description = "Maximum period of inactivity on a connection before it is closed."
}

locals {
  network_tags = var.network_tags == null ? ["requires-nat-${local.region}"] : var.network_tags

  region = join("-", slice(split("-", var.zone), 0, 2))

  startup_script = file("${path.module}/startup_script.sh")

  instance_metadata = {
    startup-script-iptables-sh = file("${path.module}/startup_script_iptables.sh")

    startup-script-sysctl-sh = (
      length(var.sysctl_config) > 0
        ? templatefile("${path.module}/startup_script_sysctl.sh", { conf = var.sysctl_config })
        : "#!/usr/bin/env bash\n\nexit 0"
    )

    startup-script-proxy-sh = (
      var.enable_http_proxy
        ? templatefile("${path.module}/startup_script_proxy.sh", {
            port = var.http_proxy_port
            address = google_compute_address.address.address
            max_connections = var.http_proxy_max_connections
            min_spare = var.http_proxy_min_spare_servers
            max_spare = var.http_proxy_max_spare_servers
            timeout = var.http_proxy_connection_timeout
          })
        : "#!/usr/bin/env bash\n\nexit 0"
    )
  }
}
