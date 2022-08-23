resource "vault_mount" "kvv2" {
  path        = "cloudflare"
  type        = "kv-v2"
  description = "This is an example KV Version 2 secret engine mount"
}

resource "vault_generic_secret" "cloudflare" {
  path = "cloudflare/credentials"

  data_json = <<EOT
{
  "account_id": "bla",
  "cloudflare_id": "bla@blamail.com",
  "cloudflare_api_key": "bla@123"
}
EOT
  depends_on = [
    vault_mount.kvv2
  ]
}