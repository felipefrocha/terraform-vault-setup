
# resource "vault_ldap_auth_backend" "ldap" {
#     path        = "local"
#     url         = "ldap://localserver.com:3268"
#     userdn      = "DC=jnj,DC=com"
#     userattr    = "sAMAccountName"
#     upndomain   = "JNJ.COM"
#     discoverdn  = false
#     groupdn     = "DC=jnj,DC=com"
#     # groupattr = "cn"
#     groupfilter = "(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))"
# }

# resource "vault_ldap_auth_backend_group" "group" {
#     groupname = "dba"
#     policies = [vault_policy.admins.name, "default"]
#     backend   = vault_ldap_auth_backend.ldap.path
# }

resource "vault_auth_backend" "user_password" {
  type = "userpass"
  path = "poc"

  tune {
    default_lease_ttl = "8h"
    max_lease_ttl      = "12h"
    listing_visibility = "hidden"
  }
}

## -----------------------------
# Create AWS Permissions for each role
## -----------------------------

resource "vault_aws_secret_backend" "aws" {
  path = "ciandt"

  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY

  # default_lease_ttl     = "3600"
  max_lease_ttl_seconds = "7200"
}


resource "vault_password_policy" "alphanumeric" {
  name   = "strongpasswd"
  policy = <<EOF
length=20

rule "charset" {
  charset = "abcdefghijklmnopqrstuvwxyz"
  min-chars = 1
}

rule "charset" {
  charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  min-chars = 3
}

rule "charset" {
  charset = "0123456789"
  min-chars = 3
}

rule "charset" {
  charset = "!@#$%^&*"
  min-chars = 2
}
EOF
}

