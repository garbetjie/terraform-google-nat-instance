Terraform Module: NAT instances (Google provider)
=================================================

A simple Terraform module for [Google Cloud Platform](https://cloud.google.com/) that creates a NAT instance to forward
traffic from internal instances without external IP addresses to the internet.

## Why?

By default, Google Compute instances without an external IP address are unable to access the internet. Google also provides
[Cloud NAT](https://cloud.google.com/nat/docs/overview) which provides the same functionality as is implemented in this
module. However, as per https://cloud.google.com/nat/docs/ports-and-addresses#ports-reuse-tcp, Google Cloud enforces a
two-minute delay before the gateway can reuse the same NAT source IP address and source port tuple with the same
destination (destination IP address, destination port, and protocol).

This poses a problem when rapidly opening and closing connections to the same destination IP, port and protocol. Google
recommends assigning an external IP address to a Google Compute instance and forwarding traffic through this instance.

This is the functionality that this module provides.

## Usage

```hcl-terraform
resource google_compute_address nat_instance {
  name = "nat-instance"
  region = "europe-west3"
}

module nat_instance_01 {
  source = "garbetjie/nat-instance/google"
  address = google_compute_address.nat_instance.address  // Required
  zone = "europe-west3-a"                                // Required
  disk_size = 15                                         // Optional
  disk_type = "pd-standard"                              // Optional
  machine_type = "f1-micro"                              // Optional
  network_tags = ["requires-nat-${local.region}"]        // Optional
  route_priority = 900                                   // Optional
  socks_proxy = { enabled = true }                       // Optional
  sysctl_config = {}                                     // Optional
  wait_duration = 10                                     // Optional
}
```

## Inputs

| Name                | Description                                                                                                                                    | Type                                                                                                          | Default                            | Required |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|------------------------------------|----------|
| address             | The external IP address to assign to this instance.                                                                                            | string                                                                                                        |                                    | Yes      |
| zone                | The zone in which to place this instance. Must be the same region as the IP address provided.                                                  | string                                                                                                        |                                    | Yes      |
| disk_size           | Size of the instance's disk (in GB)                                                                                                            | number                                                                                                        | `15`                               | No       |
| disk_type           | Type of the instance's disk (one of `pd-standard` or `pd-ssd`). `google` provider `>= 3.37` allows the option of `pd-balanced` to be provided. | string                                                                                                        | `pd-standard`                      | No       |
| machine_type        | Machine type of the instance.                                                                                                                  | string                                                                                                        | `f1-micro`                         | No       |
| network_tags        | Tags to which this route applies.                                                                                                              | list(string)                                                                                                  | `["requires-nat-${local.region}"]` | No       |
| route_priority      | The priority to assign the networking route that routes traffic through this instance.                                                         | number                                                                                                        | `900`                              | No       |
| socks_proxy         | Configuration for enabling a SOCKS proxy on this instance.                                                                                     | object({ enabled=bool, debug=optional(number), port=optional(number), allowed_ranged=optional(set(string)) }) | `{ enabled = false }`              | No       |
| socks_proxy.enabled | Flag used to enable/disable the SOCKS proxy.                                                                                                   | bool                                                                                                          | `false`                            | No       |
| socks_proxy.debug   | Debug log level used in the SOCKS proxy. Can be one of `0`, `1`, or `2`.                                                                       | number                                                                                                        | `0`                                | No       |
| socks_proxy.port    | Port on which to bind the SOCKS proxy.                                                                                                         | number                                                                                                        | `8888`                             | No       |
| allowed_ranges      | CIDR ranges allowed to connect to the proxy. Firewall rules will also be configured to allow these ranges to connect on the specified port.    | set(string)                                                                                                   | `[]`                               | No       |
| sysctl_config       | sysctl configuration to apply on startup.                                                                                                      | map(string)                                                                                                   | `{}`                               | No       |
| wait_duration       | The duration (in seconds) to wait for the NAT instance to finish starting up.                                                                  | number                                                                                                        | `10`                               | No       |


## Outputs

| Name           | Description                                                                            |
|----------------|----------------------------------------------------------------------------------------|
| address        | Internal IP address of this NAT instance.                                              |
| disk_size      | Size of the instance's disk (in GB).                                                   |
| disk_type      | Type of the instance's disk.                                                           |
| instance_name  | Name of the Compute Engine instance.                                                   |
| machine_type   | Machine type of the instance.                                                          |
| nat_address    | NAT IP address of this NAT instance.                                                   |
| network_tags   | Tags to which this instance's routes applies.                                          |
| route_name     | Name of the route used to route traffic through the instance.                          |
| route_priority | Priority assigned to the networking route used to route traffic through this instance. |
| socks_proxy    | SOCKS proxy configuration applied to the NAT instance.                                 |
| sysctl_config  | sysctl config applied on NAT instance boot.                                            |
| wait_duration  | The duration (in seconds) that was allowed for the NAT instance to finish booting.     |
| zone           | Zone in which the Compute Engine instance has been placed.                             |



## Changelog

* **3.0.1**
  * Fix incorrect assumption that default value of `var.network_tags` is `null` when checking for empty tags.  

* **3.0.0**
  * Remove HTTP forward proxy, and replaced it with a SOCKS proxy.

* **2.0.0**
  * Enable functioning as an HTTP forward proxy.
