resource "hetznerdns_zone" "domain" {
  count = var.enable_dns ? 1 : 0
  name  = var.domain
  ttl   = 3600
}

resource "hetznerdns_record" "ns1" {
  count   = var.enable_dns ? 1 : 0
  zone_id = hetznerdns_zone.domain[0].id
  name    = "@"
  value   = "hydrogen.ns.hetzner.com."
  type    = "NS"
  ttl     = 3600
}

resource "hetznerdns_record" "ns2" {
  count   = var.enable_dns ? 1 : 0
  zone_id = hetznerdns_zone.domain[0].id
  name    = "@"
  value   = "oxygen.ns.hetzner.com."
  type    = "NS"
  ttl     = 3600
}

resource "hetznerdns_record" "ns3" {
  count   = var.enable_dns ? 1 : 0
  zone_id = hetznerdns_zone.domain[0].id
  name    = "@"
  value   = "helium.ns.hetzner.de."
  type    = "NS"
  ttl     = 3600
}

# A record pointing to LB (when LB enabled) or first web server (when no LB)
resource "hetznerdns_record" "root" {
  count   = var.enable_dns ? 1 : 0
  zone_id = hetznerdns_zone.domain[0].id
  name    = "@"
  value   = var.enable_lb ? hcloud_load_balancer.web[0].ipv4 : hcloud_server.web[0].ipv4_address
  type    = "A"
  ttl     = 300
}

resource "hetznerdns_record" "www" {
  count   = var.enable_dns ? 1 : 0
  zone_id = hetznerdns_zone.domain[0].id
  name    = "www"
  value   = var.enable_lb ? hcloud_load_balancer.web[0].ipv4 : hcloud_server.web[0].ipv4_address
  type    = "A"
  ttl     = 300
}

resource "hcloud_managed_certificate" "web" {
  count        = var.enable_lb && var.enable_dns && var.enable_managed_cert ? 1 : 0
  name         = "${var.project_name}-cert"
  domain_names = [var.domain, "www.${var.domain}"]

  depends_on = [
    hetznerdns_record.root,
    hetznerdns_record.www
  ]
}
