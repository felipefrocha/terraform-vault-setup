variable "inbound_cidrs" {
  type        = list(string)
  description = "List of cidrs used to confirm approle requests without secret_id"
  default     = ["172.10.0.0/24"]
}
variable "microservice" {
  type        = string
  description = "Name of the micorservice where will be stores all their secrets and manage access roles and policies"
  default     = "microservice-users"
}
variable "secret_path" {
  description = "This object should contain all secrets that will be used in valt realted to that microservice"
  # sensitive   = true
}
variable "vault_postgres_connection_name" {

}
variable "postgres_mount_path" {}