data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

server {
  # license_path is required for Nomad Enterprise as of Nomad v1.1.1+
  #license_path = "/etc/nomad.d/license.hclic"
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
  servers = ["127.0.0.1"]
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
  #allow_privileged = true
}

consul {
  address = "127.0.0.1:8500"
  auto_advertise = true
  client_auto_join = true
}