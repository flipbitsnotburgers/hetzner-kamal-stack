variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "ssh_key_path" {
  description = "Path to SSH public key file"
  type        = string
}

variable "project_name" {
  description = "Project name used to prefix resources"
  type        = string
  default     = "app"
}

variable "web_count" {
  description = "Number of web servers to create"
  type        = number
  default     = 1
}

variable "accessories_count" {
  description = "Number of accessories servers to create"
  type        = number
  default     = 1
}

variable "server_location" {
  description = "Location for the servers (hel1, fsn1, nbg1, ash, hil, sin)"
  type        = string
  default     = "hel1"
}

variable "server_type" {
  description = "Server type (e.g., cax11, cpx11)"
  type        = string
  default     = "cax11"
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH into servers"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

# Optional features
variable "enable_lb" {
  description = "Enable Hetzner Load Balancer"
  type        = bool
  default     = false
}

variable "enable_dns" {
  description = "Enable Hetzner DNS zone management"
  type        = bool
  default     = false
}

variable "enable_managed_cert" {
  description = "Enable managed SSL certificate on LB (requires enable_lb and enable_dns)"
  type        = bool
  default     = false
}

variable "domain" {
  description = "Domain name (required when enable_dns is true)"
  type        = string
  default     = ""

  validation {
    condition     = var.enable_dns == false || (var.enable_dns == true && length(var.domain) > 0)
    error_message = "domain is required when enable_dns is true"
  }
}

variable "hetzner_dns_token" {
  description = "Hetzner DNS API Token (required only when enable_dns = true)"
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.enable_dns == false || (var.enable_dns == true && length(var.hetzner_dns_token) > 0)
    error_message = "hetzner_dns_token is required when enable_dns is true"
  }
}

# Volume sizes (0 = no volume, use local disk)
variable "postgres_volume_size" {
  description = "Size of Postgres data volume in GB (0 to disable)"
  type        = number
  default     = 0
}

variable "redis_volume_size" {
  description = "Size of Redis data volume in GB (0 to disable)"
  type        = number
  default     = 0
}
