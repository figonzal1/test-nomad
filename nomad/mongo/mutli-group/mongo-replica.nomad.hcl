# MONGO REPLICA SET
# 3 NODOS MONGO
job "mongo-replica-set" {
  datacenters = ["dc1"]
  type        = "service"


  // Grupo para el primer nodo del ReplicaSet
  group "mongo1" {
    network {
      mode = "host"
      port "mongo" {
        static = 27017
      }
    }

    task "mongo" {
      driver = "docker"

      config {
        image = "mongo:latest"
        ports = ["mongo"]
        force_pull = false
        entrypoint = [
          "bash", "-c",
          <<EOF
          if [ ! -f /data/configdb/keyfile ]; then
            echo $${MONGO_REPLICA_SET_KEY} > /data/configdb/keyfile &&
            chmod 400 /data/configdb/keyfile &&
            chown mongodb:mongodb /data/configdb/keyfile
          fi;
          exec docker-entrypoint.sh mongod --replSet rs0 --port ${NOMAD_PORT_mongo} --bind_ip_all --keyFile /data/configdb/keyfile
          EOF
        ]
        volumes = [
          "mongo_data1:/data/db:rw",
          "mongo_config1:/data/configdb:rw"
        ]

        volume_driver = "local"
      }

      env {
        MONGO_INITDB_ROOT_USERNAME = "root"
        MONGO_INITDB_ROOT_PASSWORD = "example"
        MONGO_REPLICA_SET_KEY      = "clavesupersecreta"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name     = "mongo1"
        port     = "mongo"
        provider = "nomad"


        check {
          name     = "mongo-tcp-check"
          type     = "tcp" # Cambiado de "script" a "tcp"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }

  // Grupo para el segundo nodo del ReplicaSet
  group "mongo2" {
    network {
      mode = "host"
      port "mongo" {
        static = 27018
      }
    }

    task "mongo" {
      driver = "docker"

      config {
        image = "mongo:latest"
        ports = ["mongo"]
        force_pull = false
        entrypoint = [
          "bash", "-c",
          <<EOF
          if [ ! -f /data/configdb/keyfile ]; then
            echo $${MONGO_REPLICA_SET_KEY} > /data/configdb/keyfile &&
            chmod 400 /data/configdb/keyfile &&
            chown mongodb:mongodb /data/configdb/keyfile
          fi;
          exec docker-entrypoint.sh mongod --replSet rs0 --port ${NOMAD_PORT_mongo} --bind_ip_all --keyFile /data/configdb/keyfile
          EOF
        ]
        volumes = [
          "mongo_data2:/data/db:rw",
          "mongo_config2:/data/configdb:rw"
        ]

        volume_driver = "local"
      }

      env {
        MONGO_INITDB_ROOT_USERNAME = "root"
        MONGO_INITDB_ROOT_PASSWORD = "example"
        MONGO_REPLICA_SET_KEY      = "clavesupersecreta"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name     = "mongo2"
        port     = "mongo"
        provider = "nomad"

        check {
          name     = "mongo-tcp-check"
          type     = "tcp" # Cambiado de "script" a "tcp"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }

  // Grupo para el tercer nodo del ReplicaSet
  group "mongo3" {
    network {
      mode = "host"
      port "mongo" {
        static = 27019
      }
    }

    task "mongo" {
      driver = "docker"

      config {
        image = "mongo:latest"
        ports = ["mongo"]
        force_pull = false
        entrypoint = [
          "bash", "-c",
          <<EOF
          if [ ! -f /data/configdb/keyfile ]; then
            echo $${MONGO_REPLICA_SET_KEY} > /data/configdb/keyfile &&
            chmod 400 /data/configdb/keyfile &&
            chown mongodb:mongodb /data/configdb/keyfile
          fi;
          exec docker-entrypoint.sh mongod --replSet rs0 --port ${NOMAD_PORT_mongo} --bind_ip_all --keyFile /data/configdb/keyfile
          EOF
        ]
        volumes = [
          "mongo_data3:/data/db:rw",
          "mongo_config3:/data/configdb:rw"
        ]

        volume_driver = "local"
      }

      env {
        MONGO_INITDB_ROOT_USERNAME = "root"
        MONGO_INITDB_ROOT_PASSWORD = "example"
        MONGO_REPLICA_SET_KEY      = "clavesupersecreta"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name     = "mongo3"
        port     = "mongo"
        provider = "nomad"

        check {
          name     = "mongo-tcp-check"
          type     = "tcp" # Cambiado de "script" a "tcp"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }
}