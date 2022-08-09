resource "vault_auth_backend" "service_approle" {
  type        = "approle"
  path        = "${var.microservice}-role"
  description = "This a app role for services in general"
  tune {
    max_lease_ttl      = "730h"
    listing_visibility = "unauth"
  }
}

resource "vault_approle_auth_backend_role" "microservice" {
  backend               = vault_auth_backend.service_approle.path
  role_name             = "${var.microservice}-role"
  token_policies        = ["${var.microservice}-policies"]
  bind_secret_id        = false
  secret_id_bound_cidrs = var.inbound_cidrs
}

resource "vault_policy" "microservice-policy" {
  name   = "${var.microservice}-policies"
  policy = data.vault_policy_document.policy_entitlements.hcl
}

data "vault_policy_document" "policy_entitlements" {
  rule {
    path         = "${var.microservice}role/*"
    capabilities = ["read", "list"]
    description  = "allow tokens for ${var.microservice}"
  }
  rule {
    path         = "${var.microservice}/*"
    capabilities = ["read", "list"]
    description  = "allow all on secrets for ${var.microservice}"
  }
  rule {
    path         = "${var.postgres_mount_path}/static-creds/${var.microservice}*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow read new credentials roted from postgres for ${var.microservice}"
  }
}

resource "vault_mount" "kvv2" {
  path        = var.microservice
  type        = "kv-v2"
  description = "KV safe for ${var.microservice} KV v2 secret engine mount"
}

resource "vault_generic_secret" "microservice_secrets" {
  for_each = var.secret_path
  path     = "${var.microservice}/static-secrets-${each.key}"

  data_json = jsonencode(each.value)
  depends_on = [
    vault_mount.kvv2
  ]
}


data "local_file" "role" {
  filename = "${path.module}/role.sql"
}

resource "vault_database_secret_backend_static_role" "service_db_access" {
  backend         = var.postgres_mount_path
  name            = var.microservice
  db_name         = var.vault_postgres_connection_name
  username        = var.microservice
  rotation_period = "604800"
  rotation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN ENCRYPTED PASSWORD '{{password}}'",
  ]
}
# "DROP ROLE \"{{name}}\"",
