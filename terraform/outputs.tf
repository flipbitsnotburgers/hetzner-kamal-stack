output "web_servers" {
  description = "Web server details"
  value = {
    for server in hcloud_server.web :
    server.name => {
      public_ip  = server.ipv4_address
      private_ip = tolist(server.network)[0].ip
    }
  }
}

output "accessories_servers" {
  description = "Accessories server details"
  value = {
    for server in hcloud_server.accessories :
    server.name => {
      public_ip  = server.ipv4_address
      private_ip = tolist(server.network)[0].ip
    }
  }
}

output "web_public_ips" {
  description = "List of web server public IPs (for DNS configuration)"
  value       = [for server in hcloud_server.web : server.ipv4_address]
}

output "accessories_public_ips" {
  description = "List of accessories server public IPs"
  value       = [for server in hcloud_server.accessories : server.ipv4_address]
}

output "lb_ipv4" {
  description = "Load balancer IPv4 address (when enabled)"
  value       = var.enable_lb ? hcloud_load_balancer.web[0].ipv4 : null
}

output "postgres_volume" {
  description = "Postgres volume details"
  value = var.postgres_volume_size > 0 && var.accessories_count > 0 ? {
    id         = hcloud_volume.postgres[0].id
    size       = hcloud_volume.postgres[0].size
    mount_path = "/mnt/postgres"
  } : null
}

output "redis_volume" {
  description = "Redis volume details"
  value = var.redis_volume_size > 0 && var.accessories_count > 0 ? {
    id         = hcloud_volume.redis[0].id
    size       = hcloud_volume.redis[0].size
    mount_path = "/mnt/redis"
  } : null
}

output "ssh_config_path" {
  description = "Path to generated SSH config file"
  value       = local_file.ssh_config.filename
}

output "ssh_private_key_path" {
  description = "Path to generated SSH private key"
  value       = local_sensitive_file.ssh_private_key.filename
}

output "ssh_public_key_path" {
  description = "Path to generated SSH public key"
  value       = local_file.ssh_public_key.filename
}

output "ssh_public_key" {
  description = "SSH public key content (for adding to other services)"
  value       = tls_private_key.deploy.public_key_openssh
}

output "connection_info" {
  description = "Quick connection info"
  value       = <<-EOT
    SSH into servers:
    %{for server in hcloud_server.web~}
      ssh ${server.name}
    %{endfor~}
    %{for server in hcloud_server.accessories~}
      ssh ${server.name}
    %{endfor~}

    %{if var.enable_lb~}
    Load Balancer IP: ${hcloud_load_balancer.web[0].ipv4}
    %{else~}
    Web Server IP: ${hcloud_server.web[0].ipv4_address}
    %{endif~}
  EOT
}
