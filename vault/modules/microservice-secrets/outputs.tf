output "role_id" {
  value = vault_approle_auth_backend_role.microservice
}

output "secrets" {
  value = vault_generic_secret.microservice_secrets
}