variable address {
  type = string
}

variable zone {
  type = string
}

variable machine_type {
  type = string
  default = "f1-micro"
}

variable disk_size {
  type = number
  default = 15
}

variable disk_type {
  type = string
  default = "pd-balanced"
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
