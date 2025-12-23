# Ensure the SSH config directory exists
resource "null_resource" "ssh_config_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ~/.ssh/config.d"
  }
}

resource "local_file" "ssh_config" {
  filename = pathexpand("~/.ssh/config.d/${var.project_name}-hetzner")
  content = templatefile("${path.module}/templates/ssh_config.tpl", {
    web_servers = [
      for idx, server in hcloud_server.web : {
        name = server.name
        ip   = server.ipv4_address
      }
    ]
    accessories_servers = [
      for idx, server in hcloud_server.accessories : {
        name = server.name
        ip   = server.ipv4_address
      }
    ]
    ssh_user     = "root"
    ssh_key_path = local_sensitive_file.ssh_private_key.filename
  })

  depends_on = [null_resource.ssh_config_dir, local_sensitive_file.ssh_private_key]
}
