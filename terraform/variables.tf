variable "kubeconfig" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "C:\Users\asus\.kube\config"
}

variable "dockerhub_user" {
  type        = string
  description = "DockerHub username"
}

variable "db_user" {
  type        = string
  description = "Postgres user"
}

variable "db_pass" {
  type        = string
  description = "Postgres password"
}

variable "db_name" {
  type        = string
  description = "Database name"
}
