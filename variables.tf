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

//variable sysctl_config {
//  type = map(string)
//  default = {}
//  description = "sysctl configuration to apply on startup."
//}

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

locals {
  network_tags = var.network_tags == null ? ["requires-nat-${local.region}"] : var.network_tags

  region = join("-", slice(split("-", var.zone), 0, 2))

  startup_script = <<EOT
#!/bin/sh
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

apt-get install -y nftables
nft add rule nat POSTROUTING masquerade
EOT
}
