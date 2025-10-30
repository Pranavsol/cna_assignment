resource "kubernetes_secret" "postgres_secret" {
  metadata {
    name = "postgres-secret"
  }

  data = {
    POSTGRES_DB       = base64encode("mydb")
    POSTGRES_USER     = base64encode(var.db_user)
    POSTGRES_PASSWORD = base64encode(var.db_pass)
  }
}
