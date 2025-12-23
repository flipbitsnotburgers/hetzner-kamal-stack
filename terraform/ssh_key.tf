# Generate SSH key pair for this project
resource "tls_private_key" "deploy" {
  algorithm = "ED25519"
}

# Upload public key to Hetzner
resource "hcloud_ssh_key" "default" {
  name       = "${var.project_name}-key"
  public_key = tls_private_key.deploy.public_key_openssh
}

# Save private key locally
resource "local_sensitive_file" "ssh_private_key" {
  filename        = pathexpand("~/.ssh/${var.project_name}-hetzner")
  content         = tls_private_key.deploy.private_key_openssh
  file_permission = "0600"
}

# Save public key locally (for reference)
resource "local_file" "ssh_public_key" {
  filename        = pathexpand("~/.ssh/${var.project_name}-hetzner.pub")
  content         = tls_private_key.deploy.public_key_openssh
  file_permission = "0644"
}
