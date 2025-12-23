locals {
  # When LB is enabled, only allow HTTP/HTTPS from the LB's private IP
  # When LB is disabled, allow from anywhere (Kamal proxy handles SSL)
  http_source_ips = var.enable_lb ? ["10.0.1.250/32"] : ["0.0.0.0/0", "::/0"]
}

resource "hcloud_firewall" "web" {
  name = "${var.project_name}-web-firewall"

  # Allow all internal network traffic
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "any"
    source_ips = [
      "10.0.1.0/24"
    ]
  }

  # SSH access
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.ssh_allowed_cidrs
  }

  # HTTP - from LB only when LB enabled, otherwise from anywhere
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = local.http_source_ips
  }

  # HTTPS - from LB only when LB enabled, otherwise from anywhere
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = local.http_source_ips
  }
}

resource "hcloud_firewall" "accessories" {
  name = "${var.project_name}-accessories-firewall"

  # Allow all internal network traffic (for Redis, Postgres, etc.)
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "any"
    source_ips = [
      "10.0.1.0/24"
    ]
  }

  # SSH access
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = var.ssh_allowed_cidrs
  }

  # HTTP - only when accessories_expose_web is enabled (for observability dashboards)
  dynamic "rule" {
    for_each = var.accessories_expose_web ? [1] : []
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = "80"
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }

  # HTTPS - only when accessories_expose_web is enabled
  dynamic "rule" {
    for_each = var.accessories_expose_web ? [1] : []
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = "443"
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }
}
