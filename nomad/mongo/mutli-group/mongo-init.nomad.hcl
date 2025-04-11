# CONFIGURACION DE REPLICA SET
# EJECUTAR DESPUES DE LANZAR LOS SERVICIOS
job "mongo-replica-init" {
  datacenters = ["dc1"]
  type        = "batch"

  group "init-replica" {
    count = 1

    network {
      mode = "host"
    }

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
# Usamos los DNS registrados en Consul
MONGO1="mongo1.service.consul"
MONGO2="mongo2.service.consul"
MONGO3="mongo3.service.consul"

# Esperamos a que el primer nodo esté listo
until mongosh --host "$MONGO1" --port 27017 -u root -p example --eval 'db.runCommand({ ping: 1 })' >/dev/null 2>&1; do
  echo "Esperando a que $MONGO1 esté disponible..."
  sleep 2
done

# Inicializar el ReplicaSet
mongosh --host "$MONGO1" --port 27017 -u root -p example --eval '
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "'$MONGO1':27017" },
    { _id: 1, host: "'$MONGO2':27018" },
    { _id: 2, host: "'$MONGO3':27019" }
  ]
})
'
EOF
        destination = "local/init-replica.sh"
        perms       = "755"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}