locals {
  web_hostnames         = [for i in range(var.web_count) : "${var.project_name}-web-${i + 1}"]
  accessories_hostnames = [for i in range(var.accessories_count) : "${var.project_name}-accessories-${i + 1}"]

  all_hosts = concat(
    [for i in range(var.web_count) : {
      name = "web-${i + 1}"
      ip   = "10.0.1.${i + 1}"
    }],
    [for i in range(var.accessories_count) : {
      name = "accessories-${i + 1}"
      ip   = "10.0.1.${var.web_count + i + 1}"
    }]
  )

  # Volume mounts for accessories servers
  accessories_volumes = merge(
    var.postgres_volume_size > 0 ? {
      postgres = {
        device = "/dev/disk/by-id/scsi-0HC_Volume_${hcloud_volume.postgres[0].id}"
        path   = "/mnt/postgres"
      }
    } : {},
    var.redis_volume_size > 0 ? {
      redis = {
        device = "/dev/disk/by-id/scsi-0HC_Volume_${hcloud_volume.redis[0].id}"
        path   = "/mnt/redis"
      }
    } : {}
  )
}

resource "hcloud_server" "web" {
  count       = var.web_count
  name        = "web-${count.index + 1}"
  server_type = var.server_type
  image       = "ubuntu-24.04"
  location    = var.server_location
  ssh_keys    = [hcloud_ssh_key.default.id]

  labels = {
    project = var.project_name
    role    = "web"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.private_network.id
    ip         = "10.0.1.${count.index + 1}"
  }

  firewall_ids = [hcloud_firewall.web.id]

  user_data = templatefile("${path.module}/templates/cloud-init.tpl", {
    hostname = "web-${count.index + 1}"
    hosts    = local.all_hosts
    volumes  = {}
  })

  depends_on = [
    hcloud_network_subnet.private_subnet
  ]
}

resource "hcloud_server" "accessories" {
  count       = var.accessories_count
  name        = "accessories-${count.index + 1}"
  server_type = var.server_type
  image       = "ubuntu-24.04"
  location    = var.server_location
  ssh_keys    = [hcloud_ssh_key.default.id]

  labels = {
    project = var.project_name
    role    = "accessories"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.private_network.id
    ip         = "10.0.1.${var.web_count + count.index + 1}"
  }

  firewall_ids = [hcloud_firewall.accessories.id]

  user_data = templatefile("${path.module}/templates/cloud-init.tpl", {
    hostname = "accessories-${count.index + 1}"
    hosts    = local.all_hosts
    volumes  = count.index == 0 ? local.accessories_volumes : {}
  })

  depends_on = [
    hcloud_network_subnet.private_subnet,
    hcloud_volume.postgres,
    hcloud_volume.redis
  ]
}
