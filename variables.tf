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
  default = "pd-balanced"
  description = "Type of the instance's disk (one of `pd-standard`, `pd-balanced` or `pd-ssd`)."
}

locals {
  region = join("-", slice(split("-", var.zone), 0, 2))

  startup_script = <<EOT
#!/bin/sh
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

apt-get install -y nftables
nft add rule nat POSTROUTING masquerade
EOT
}
