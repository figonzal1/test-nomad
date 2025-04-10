# CONFIGURACION DE REPLICA SET
# EJECUTAR DESPUES DE LANZAR LOS SERVICIOS
job "mongo-replica-init" {
  datacenters = ["dc1"]
  type        = "batch" # Este job se ejecutará solo una vez

  periodic {
    prohibit_overlap = false  # Permite solapamientos
  }

  group "init-replica" {
    count = 1

    task "init" {
      driver = "docker"

      config {
        image   = "mongo:latest"
        command = "sh"
        args    = ["local/init-replica.sh"]
      }

      template {
        data        = <<EOF
#!/bin/sh
# Usar las direcciones IP directamente desde las variables de Nomad
MONGO1_IP="{{ range nomadService "mongo1" }}{{ .Address }}{{ end }}"
MONGO2_IP="{{ range nomadService "mongo2" }}{{ .Address }}{{ end }}"
MONGO3_IP="{{ range nomadService "mongo3" }}{{ .Address }}{{ end }}"

# Esperar a que los servicios estén disponibles
until mongosh --host $MONGO1_IP --port 27017 -u root -p example --eval 'db.runCommand({ ping: 1 })' >/dev/null 2>&1; do
  echo "Esperando a que mongo1 esté disponible..."
  sleep 2
done

# Inicializar el replica set
mongosh --host $MONGO1_IP --port 27017 -u root -p example --eval '
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "'$MONGO1_IP':27017" },
    { _id: 1, host: "'$MONGO2_IP':27018" },
    { _id: 2, host: "'$MONGO3_IP':27019" }
  ]
})
'
EOF
        destination = "local/init-replica.sh" # <-- Añade esta línea
        perms       = "755"                   # <-- Y esta para permisos de ejecución
      }
    }
  }
}