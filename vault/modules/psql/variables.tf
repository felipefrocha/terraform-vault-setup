
variable "databases" {
  type = map(object({
    password = string
    dba      = string
    url      = string
    port     = number
    db_name  = string
  }))
  description = "Map of objects with the desired configs for each database"
  sensitive   = true
}