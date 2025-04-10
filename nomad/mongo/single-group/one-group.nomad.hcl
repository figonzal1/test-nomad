# NO USAR ESTA VERSION
# Los contenedores de mongo no son manejables individualmente
job "mongo-replica-set" {
  datacenters = ["dc1"]
  type = "service"

  group "mongo-cluster" {
    network {
      mode = "host"
      port "mongo1" {
        static = 27017
      }
      port "mongo2" {
        static = 27018
      }
      port "mongo3" {
        static = 27019
      }
    }

    task "mongo1" {
      driver = "docker"
      
      config {
        image = "mongo:latest"
        ports = ["mongo1"]
        entrypoint = [
          "bash", "-c",
          <<EOF
          if [ ! -f /data/configdb/keyfile ]; then
            echo $${MONGO_REPLICA_SET_KEY} > /data/configdb/keyfile &&
            chmod 400 /data/configdb/keyfile &&
            chown mongodb:mongodb /data/configdb/keyfile
          fi;
          exec docker-entrypoint.sh mongod --replSet rs0 --port 27017 --bind_ip_all --keyFile /data/configdb/keyfile
          EOF
        ]
      }

      env {
        MONGO_INITDB_ROOT_USERNAME = "root"
        MONGO_INITDB_ROOT_PASSWORD = "example"
        MONGO_REPLICA_SET_KEY     = "clavesupersecreta"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name = "mongo1"
        port = "mongo1"
        
        check {
          name     = "mongo-health"
          type     = "script"
          command  = "mongosh"
          args     = ["--quiet", "--port", "27017", "--eval", "db.runCommand({ ping: 1 }).ok"]
          interval = "5s"
          timeout  = "2s"
        }
      }
    }

    task "mongo2" {
      driver = "docker"
      
      config {
        image = "mongo:latest"
        ports = ["mongo2"]
        entrypoint = [
          "bash", "-c",
          <<EOF
          if [ ! -f /data/configdb/keyfile ]; then
            echo $${MONGO_REPLICA_SET_KEY} > /data/configdb/keyfile &&
            chmod 400 /data/configdb/keyfile &&
            chown mongodb:mongodb /data/configdb/keyfile
          fi;
          exec docker-entrypoint.sh mongod --replSet rs0 --port 27018 --bind_ip_all --keyFile /data/configdb/keyfile
          EOF
        ]
      }

      env {
        MONGO_INITDB_ROOT_USERNAME = "root"
        MONGO_INITDB_ROOT_PASSWORD = "example"
        MONGO_REPLICA_SET_KEY     = "clavesupersecreta"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name = "mongo2"
        port = "mongo2"
        
        check {
          name     = "mongo-health"
          type     = "script"
          command  = "mongosh"
          args     = ["--quiet", "--port", "27018", "--eval", "db.runCommand({ ping: 1 }).ok"]
          interval = "5s"
          timeout  = "2s"
        }
      }
    }

    task "mongo3" {
      driver = "docker"
      
      config {
        image = "mongo:latest"
        ports = ["mongo3"]
        entrypoint = [
          "bash", "-c",
          <<EOF
          if [ ! -f /data/configdb/keyfile ]; then
            echo $${MONGO_REPLICA_SET_KEY} > /data/configdb/keyfile &&
            chmod 400 /data/configdb/keyfile &&
            chown mongodb:mongodb /data/configdb/keyfile
          fi;
          exec docker-entrypoint.sh mongod --replSet rs0 --port 27019 --bind_ip_all --keyFile /data/configdb/keyfile
          EOF
        ]
      }

      env {
        MONGO_INITDB_ROOT_USERNAME = "root"
        MONGO_INITDB_ROOT_PASSWORD = "example"
        MONGO_REPLICA_SET_KEY     = "clavesupersecreta"
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      service {
        name = "mongo3"
        port = "mongo3"
        
        check {
          name     = "mongo-health"
          type     = "script"
          command  = "mongosh"
          args     = ["--quiet", "--port", "27019", "--eval", "db.runCommand({ ping: 1 }).ok"]
          interval = "5s"
          timeout  = "2s"
        }
      }
    }

    task "init-replica" {
      driver = "docker"
      
      config {
        image = "mongo:latest"
        command = "sh"
        args    = ["local/init-replica.sh"]
      }

      lifecycle {
        hook = "poststart"
        sidecar = false
      }

      env {
        MONGO_INITDB_ROOT_USERNAME = "root"
        MONGO_INITDB_ROOT_PASSWORD = "example"
      }

      resources {
        cpu    = 100
        memory = 128
      }

      template {
        data = <<EOF
#!/bin/sh
mongosh --host {{ env "NOMAD_IP_mongo1" }} --port {{ env "NOMAD_PORT_mongo1" }} -u root -p example --eval '
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "{{ env "NOMAD_IP_mongo1" }}:{{ env "NOMAD_PORT_mongo1" }}" },
    { _id: 1, host: "{{ env "NOMAD_IP_mongo2" }}:{{ env "NOMAD_PORT_mongo2" }}" },
    { _id: 2, host: "{{ env "NOMAD_IP_mongo3" }}:{{ env "NOMAD_PORT_mongo3" }}" },
  ]
})
'
EOF
        destination = "local/init-replica.sh"
        perms       = "755"
      }
    }
  }
}