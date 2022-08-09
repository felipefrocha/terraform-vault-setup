storage "file" {
    path    = "/vault/config"
}

listener "tcp" {
    address     = "0.0.0.0:8200"
    cluster_address = "0.0.0.0:8201"
    tls_disable = "true"
}

disable_mlock = true

api_addr = "http://127.0.0.1:8200"
cluster_addr = "https://127.0.0.1:8201"

ui = true

default_lease_ttl = "1h"
max_lease_ttl = "24h"

log_level = "Debug"