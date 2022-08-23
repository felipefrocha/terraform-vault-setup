variable "server_name" {
  default = "pegasus"
}

variable "certifficate_name" {
  default = "tls"
}

variable "download_certs" {
  default = false
}

variable "common_name" {
  default = "vault.local"
}

variable "organization_name" {
  default = "ciandt"
}

variable "project" {
  default = "hackathon"
}

variable "environment" {
  default = "dev"
}

variable "server_address" {
  default = "pegasus.local"
}

variable "permissions" {
  default = "0600"
}


/**
 * Create TLS Bastion Vault Consul
 */

module "root_tls_self_signed_ca" {
  source            = "git@github.com:felipefrocha/terraform-tls-certificate.git"
  project           = var.project
  environment       = var.environment
  name              = format("%s-root", var.certifficate_name)
  ca_common_name    = var.common_name
  organization_name = var.organization_name
  common_name       = var.common_name
  download_certs    = var.download_certs

  validity_period_hours = "26280"

  ca_allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

module "leaf_tls_self_signed_cert" {
  source      = "git@github.com:felipefrocha/terraform-tls-certificate.git"
  project     = var.project
  environment = var.environment

  name              = format("%s-leaf", var.certifficate_name)
  organization_name = var.organization_name
  common_name       = var.common_name
  ca_override       = true
  ca_key_override   = module.root_tls_self_signed_ca.ca_private_key_pem
  ca_cert_override  = module.root_tls_self_signed_ca.ca_cert_pem
  download_certs    = var.download_certs

  validity_period_hours = "26280"

  dns_names = [
    "localhost",
    "*.node.consul",
    "*.service.consul",
    "server.dc1.consul",
    "*.dc1.consul",
    "server.${var.server_name}.consul",
    "*.${var.server_name}.local",
    "*.${var.server_name}.svc",
    "*.${var.server_name}.svc.local",
  ]

  ip_addresses = [
    "0.0.0.0",
    "127.0.0.1",
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

# resource "null_resource" "download_ca_cert" {
#   provisioner "local-exec" {
#     command = format("echo '%s' > tls.crt.pem && chmod %s 'tls.crt.pem'",module.root_tls_self_signed_ca.ca_cert_pem, var.permissions)
#   }
# }

# resource "null_resource" "download_ca_key" {
#   provisioner "local-exec" {
#     command = format("echo '%s' > tls.key.pem && chmod %s 'tls.key.pem'", module.root_tls_self_signed_ca.private_key_pem, var.permissions)
#   }
# }

output "root_ca_private_key_pem" {
  value     = module.root_tls_self_signed_ca.private_key_pem
  sensitive = true
}

output "root_ca_cert_pem" {
  value     = module.root_tls_self_signed_ca.ca_cert_pem
  sensitive = true
}

output "leaf_cert_pem" {
  value     = module.leaf_tls_self_signed_cert.leaf_cert_pem
  sensitive = true
}

output "leaf_key_pem" {
  value     = module.leaf_tls_self_signed_cert.leaf_private_key_pem
  sensitive = true
}


resource "null_resource" "mv_keys" {
  triggers = {
    "time" = timestamp()
  }

  connection {
    host = var.server_address
    type = "ssh"
    user = "rocha"
  }

  provisioner "file" {
    content = module.root_tls_self_signed_ca.ca_cert_pem
    destination = "/tmp/tls-ca.crt" 
  }

  provisioner "file" {
    content = module.leaf_tls_self_signed_cert.leaf_private_key_pem
    destination = "/tmp/tls.key"
  }

  provisioner "file" {
    content = <<EOT
    VAULT_ADDR=https://127.0.0.1:8200
    VAULT_SKIP_VERIFY=false
    VAULT_CACERT=/opt/vault/tls/tls-ca.crt
    VAULT_CLIENT_CERT=/opt/vault/tls/tls.crt
    VAULT_CLIENT_KEY=/opt/vault/tls/tls.key
    EOT
    destination = "/tmp/vault.env"
  }

  provisioner "file" {
    content = module.leaf_tls_self_signed_cert.leaf_cert_pem
    destination = "/tmp/tls.crt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/tls* /opt/vault/tls/",
      "sudo mv /tmp/vault.env /etc/vault.d/",
      "sudo chown -R vault:vault /opt/vault/tls/",
      "sudo chmod 640 /opt/vault/tls/",
      "sudo sed -i -E 's|\\/opt\\/vault\\/tls\\/tls\\.crt.*|/opt/vault/tls/tls.crt\"|g' /etc/vault.d/vault.hcl",
      "sudo sed -i -E 's|\\/opt\\/vault\\/tls\\/tls\\.key.*|/opt/vault/tls/tls.key\"|g' /etc/vault.d/vault.hcl",
      "sudo systemctl restart vault",
    ]
  }
  # depends_on = [
  #   null_resource.download_ca_cert,
  #   null_resource.download_ca_key
  # ]
}