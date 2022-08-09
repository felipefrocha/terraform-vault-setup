resource "vault_aws_secret_backend_role" "queima_adm" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "ciandt-adm"
  role_arns       = ["arn:aws:iam::553735337563:role/VaultAdministratorRole"]
  credential_type = "assumed_role"
  default_sts_ttl = "3600"
  max_sts_ttl     = "7200"
}

resource "vault_policy" "admins" {
  name   = "admins"
  policy = data.vault_policy_document.admins.hcl
}

data "vault_policy_document" "admins" {
  rule {
    path         = "secret/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets"
  }

  rule {
    description  = "Read system health check|"
    path         = "sys/health"
    capabilities = ["read", "sudo"]
  }

  # Create and manage ACL policies broadly across Vault
  rule {
    description  = "List existing policies|"
    path         = "sys/policies/acl"
    capabilities = ["list"]
  }
  rule {
    description  = "Create and manage ACL policies|"
    path         = "sys/policies/acl/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  # Enable and manage authentication methods broadly across Vault
  rule {
    description  = "Manage auth methods broadly across Vault|"
    path         = "auth/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    description  = "Create, update, and delete auth methods|"
    path         = "sys/auth/*"
    capabilities = ["create", "update", "delete", "sudo"]
  }

  rule {
    description  = "List auth methods|"
    path         = "sys/auth"
    capabilities = ["read"]
  }

  rule {
    description  = "Create, update, and delete auth methods|"
    path         = "sys/policies/password/*"
    capabilities = ["create", "update", "delete", "sudo"]
  }

  rule {
    description  = "List auth methods|"
    path         = "sys/policies/password/strongpasswd/*"
    capabilities = ["read"]
  }

  # Enable and manage the key/value secrets engine at `secret/` path
  rule {
    description  = "List, create, update, and delete key/value secrets|"
    path         = "secret/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    description  = "Manage secrets engines|"
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    description  = "List existing secrets engines.|"
    path         = "sys/mounts"
    capabilities = ["read"]
  }

  # Enable and manage the secrets engine `queimadiaria/` path
  rule {
    description  = "List, create, update, and delete key/value secrets|"
    path         = "ciandt/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  rule {
    description  = "List, create, update, and delete key/value secrets|"
    path         = "poc/*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  dynamic "rule" {
    for_each = ["test","back"]
    content {
      description  = "List, create, update and delete data for ${rule.value}"
      path         = "${rule.value}/*"
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
  }
}

