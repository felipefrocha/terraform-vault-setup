## Postgres RDS Regulation
resource "vault_mount" "this" {
  path = "postgres"
  type = "database"
}

resource "vault_database_secret_backend_connection" "rds_main" {
  backend       = vault_mount.postgres_rds.path
  name          = "main-prod"
  allowed_roles = ["main-prod","microservice-*"] 

  postgresql {
    connection_url = "postgres://${var.databases.main_prod.dba}:${var.databases.main_prod.password}@${var.databases.main_prod.url}:${var.databases.main_prod.port}/${var.databases.main_prod.db_name}"
  }
}


resource "vault_database_secret_backend_role" "role_main" {
  backend = vault_mount.postgres_rds.path
  name    = "main-prod"
  db_name = vault_database_secret_backend_connection.rds_main.name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT postgres to \"{{name}}\";"
  ]
  revocation_statements = [
    "DROP ROLE IF EXISTS \"{{name}}\";",
  ]
  default_ttl = "86400"
  max_ttl     = "30879000"
}
