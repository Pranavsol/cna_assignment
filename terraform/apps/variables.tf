variable "dockerhub_user" {
  description = "DockerHub username for pulling images"
}

variable "db_name" {
  description = "Postgres database name"
  default     = "serviceadb"
}

variable "db_user" {
  description = "Postgres database user"
}

variable "db_pass" {
  description = "Postgres database password"
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  default     = "~/.kube/config"
}
