# Postgres volume (attached to first accessories server)
resource "hcloud_volume" "postgres" {
  count    = var.postgres_volume_size > 0 ? 1 : 0
  name     = "${var.project_name}-postgres"
  size     = var.postgres_volume_size
  location = var.server_location
  format   = "ext4"
}

resource "hcloud_volume_attachment" "postgres" {
  count     = var.postgres_volume_size > 0 ? 1 : 0
  volume_id = hcloud_volume.postgres[0].id
  server_id = hcloud_server.accessories[0].id
  automount = false
}

# Redis volume (attached to first accessories server)
resource "hcloud_volume" "redis" {
  count    = var.redis_volume_size > 0 ? 1 : 0
  name     = "${var.project_name}-redis"
  size     = var.redis_volume_size
  location = var.server_location
  format   = "ext4"
}

resource "hcloud_volume_attachment" "redis" {
  count     = var.redis_volume_size > 0 ? 1 : 0
  volume_id = hcloud_volume.redis[0].id
  server_id = hcloud_server.accessories[0].id
  automount = false
}
