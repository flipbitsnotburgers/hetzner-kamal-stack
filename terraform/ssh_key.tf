data "local_file" "ssh_key" {
  filename = pathexpand(var.ssh_key_path)
}

resource "hcloud_ssh_key" "default" {
  name       = "${var.project_name}-key"
  public_key = data.local_file.ssh_key.content
}
