variable "kubeconfig_path" {
  default = "~/.kube/config"
}

variable "dockerhub_user" {
  description = "Docker Hub username for pulling images"
}

variable "db_user" {
  description = "Postgres username"
}

variable "db_pass" {
  description = "Postgres password"
}

variable "db_name" {
  default = "serviceadb"
}
