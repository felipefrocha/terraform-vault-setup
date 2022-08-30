resource "vault_auth_backend" "jenkins_approle" {
  type        = "approle"
  path        = "jenkins"
  description = "This a app role for jenkins runners in general"
  tune {
    max_lease_ttl      = "730h"
    listing_visibility = "unauth"
  }
}

resource "vault_approle_auth_backend_role" "jenkins" {
  backend               = vault_auth_backend.jenkins_approle.path
  role_name             = "jenkins-role"
  token_policies        = ["jenkins-policy"]
  bind_secret_id        = false
  secret_id_bound_cidrs = ["10.0.0.0/8"]
}

resource "vault_policy" "jenkins_policy" {
  name   = "jenkins-policy"
  policy = data.vault_policy_document.jenkins_policy.hcl
}

data "vault_policy_document" "jenkins_policy" {
  rule {
    path         = "cloudflare/*"
    capabilities = ["read", "list"]
    description  = "allow all on secrets"
  }
}