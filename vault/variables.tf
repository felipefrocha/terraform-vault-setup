
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

variable "vault_addr" {
  type    = string
  default = "http://127.0.0.1:8200"
}


variable "vault_token" {
  type        = string
  default     = ""
  description = "Vault token with root credentials"
  sensitive   = true
}
