resource "vault_mount" "this_kvv2" {
  path        = "${var.system_nam}"
  type        = "kv-v2"
  description = "This is an example KV Version 2 secret engine mount"
}

resource "vault_generic_secret" "this" {
  path = "${var.system_nam}/credentials"

  data_json = <<EOT
{
  "${var.system_nam}_key": "bla_123"
}
EOT
  depends_on = [
    vault_mount.this_kvv2
  ]
}