locals {
  # Map server locations to network zones
  network_zone_map = {
    "hel1" = "eu-central"
    "fsn1" = "eu-central"
    "nbg1" = "eu-central"
    "ash"  = "us-east"
    "hil"  = "us-west"
    "sin"  = "ap-southeast"
  }
  network_zone = lookup(local.network_zone_map, var.server_location, "eu-central")
}

resource "hcloud_network" "private_network" {
  name     = "${var.project_name}-private-net"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "private_subnet" {
  network_id   = hcloud_network.private_network.id
  type         = "cloud"
  network_zone = local.network_zone
  ip_range     = "10.0.1.0/24"
}
