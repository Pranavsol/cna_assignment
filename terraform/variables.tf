variable "kubeconfig" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_user" {
  description = "PostgreSQL database user"
  type        = string
}

variable "db_pass" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "dockerhub_user" {
  description = "DockerHub username"
  type        = string
}