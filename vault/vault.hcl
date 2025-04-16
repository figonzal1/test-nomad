storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1  # Solo para pruebas (en producci  n usa TLS)
}

api_addr = "http://0.0.0.0:8200"  # Reemplaza con la IP de tu servidor

ui = true  # Habilita la interfaz web