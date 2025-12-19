resource "hcloud_load_balancer" "web" {
  count              = var.enable_lb ? 1 : 0
  name               = "${var.project_name}-lb"
  load_balancer_type = "lb11"
  location           = var.server_location
}

resource "hcloud_load_balancer_network" "private_network" {
  count            = var.enable_lb ? 1 : 0
  load_balancer_id = hcloud_load_balancer.web[0].id
  network_id       = hcloud_network.private_network.id
  ip               = "10.0.1.250"

  depends_on = [
    hcloud_network_subnet.private_subnet
  ]
}

resource "hcloud_load_balancer_target" "web_servers" {
  count            = var.enable_lb ? var.web_count : 0
  type             = "server"
  load_balancer_id = hcloud_load_balancer.web[0].id
  server_id        = hcloud_server.web[count.index].id
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_network.private_network
  ]
}

resource "hcloud_load_balancer_service" "web_https" {
  count            = var.enable_lb && var.enable_managed_cert ? 1 : 0
  load_balancer_id = hcloud_load_balancer.web[0].id
  protocol         = "https"
  listen_port      = 443
  destination_port = 80

  http {
    certificates  = [hcloud_managed_certificate.web[0].id]
    redirect_http = true
  }

  health_check {
    protocol = "http"
    port     = 80
    interval = 15
    timeout  = 10
    retries  = 3
    http {
      path         = "/up"
      status_codes = ["2??"]
    }
  }

  depends_on = [
    hcloud_load_balancer_network.private_network
  ]
}

# HTTP-only service when no managed cert (for testing or manual cert setup)
resource "hcloud_load_balancer_service" "web_http" {
  count            = var.enable_lb && !var.enable_managed_cert ? 1 : 0
  load_balancer_id = hcloud_load_balancer.web[0].id
  protocol         = "http"
  listen_port      = 80
  destination_port = 80

  health_check {
    protocol = "http"
    port     = 80
    interval = 15
    timeout  = 10
    retries  = 3
    http {
      path         = "/up"
      status_codes = ["2??"]
    }
  }

  depends_on = [
    hcloud_load_balancer_network.private_network
  ]
}
