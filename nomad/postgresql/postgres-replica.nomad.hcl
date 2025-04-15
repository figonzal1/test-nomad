job "postgresql-replica" {
  datacenters = ["dc1"]
  type        = "service"

  group "pg-0" {
    network {
      mode = "host"
      port "db" {
        static = 5433
      }
    }

    task "pg-0" {
      driver = "docker"

      config {
        image = "bitnami/postgresql-repmgr:14"
        ports = ["db"]
        volumes = [
          "pg_0_data:/bitnami/postgresql:rw"
        ]
        volume_driver = "local"
        dns_servers   = ["127.0.0.1"]
      }

      env {
        POSTGRESQL_POSTGRES_PASSWORD = "syncpass"

        POSTGRESQL_USERNAME = "customuser"
        POSTGRESQL_PASSWORD = "custompassword"
        POSTGRESQL_DATABASE = "customdatabase"

        POSTGRESQL_PORT_NUMBER = 5433
        REPMGR_PRIMARY_PORT    = 5433
        REPMGR_PORT_NUMBER     = 5433

        REPMGR_USERNAME          = "repmgr"
        REPMGR_PASSWORD          = "repmgrpassword"
        REPMGR_PRIMARY_HOST      = "192.168.10.45"
        REPMGR_PARTNER_NODES     = "192.168.10.45:5433,192.168.10.45:5434"
        REPMGR_NODE_NAME         = "pg-0"
        REPMGR_NODE_NETWORK_NAME = "192.168.10.45"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name     = "pg-0"
        port     = "db"
        provider = "consul"
        tags     = ["postgresql", "pg-0"]
      }
    }
  }

  group "pg-1" {
    network {
      mode = "host"
      port "db" {
        static = 5434
      }
    }

    task "pg-1" {
      driver = "docker"

      config {
        image = "bitnami/postgresql-repmgr:14"
        ports = ["db"]
        volumes = [
          "pg_1_data:/bitnami/postgresql:rw"
        ]
        volume_driver = "local"
        dns_servers   = ["127.0.0.1"]
      }

      env {
        POSTGRESQL_POSTGRES_PASSWORD = "syncpass"

        POSTGRESQL_USERNAME = "customuser"
        POSTGRESQL_PASSWORD = "custompassword"
        POSTGRESQL_DATABASE = "customdatabase"

        POSTGRESQL_PORT_NUMBER = 5434
        REPMGR_PRIMARY_PORT    = 5433
        REPMGR_PORT_NUMBER     = 5434

        REPMGR_USERNAME          = "repmgr"
        REPMGR_PASSWORD          = "repmgrpassword"
        REPMGR_PRIMARY_HOST      = "192.168.10.45"
        REPMGR_PARTNER_NODES     = "192.168.10.45:5433,192.168.10.45:5434"
        REPMGR_NODE_NAME         = "pg-1"
        REPMGR_NODE_NETWORK_NAME = "192.168.10.45"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name     = "pg-1"
        port     = "db"
        provider = "consul"
        tags     = ["postgresql", "pg-1"]
      }
    }
  }


  group "pgpool" {
    network {
      mode = "host"
      port "postgres" {
        static = 5432
      }
    }

    task "pgpool" {
      driver = "docker"

      config {
        image       = "bitnami/pgpool:4"
        ports       = ["postgres"]
        dns_servers = ["127.0.0.1"]
      }

      lifecycle {
        hook    = "poststart"
        sidecar = true
      }

      env {
        # Configuración básica
        PGPOOL_BACKEND_NODES = "0:192.168.10.45:5433,1:192.168.10.45:5434"

        # Autenticación
        PGPOOL_SR_CHECK_USER     = "customuser"
        PGPOOL_SR_CHECK_PASSWORD = "custompassword" # Debe coincidir con POSTGRESQL_PASSWORD
        PGPOOL_POSTGRES_USERNAME = "postgres"
        PGPOOL_POSTGRES_PASSWORD = "syncpass" # Debe conincidir con POSTGRESQL_POSTGRES_PASSWORD de replicas
        PGPOOL_ADMIN_USERNAME    = "admin"
        PGPOOL_ADMIN_PASSWORD    = "admin123"

        PGPOOL_REPMGR_USERNAME = "repmgr"
        PGPOOL_REPMGR_PASSWORD = "repmgrpassword"


        # Failover automático
        PGPOOL_ENABLE_LOAD_BALANCING    = "yes"
        #PGPOOL_HEALTH_CHECK_PERIOD      = 10
        #PGPOOL_HEALTH_CHECK_TIMEOUT     = 10
        #PGPOOL_HEALTH_CHECK_MAX_RETRIES = 5
        #PGPOOL_HEALTH_CHECK_RETRY_DELAY = 5
        #PGPOOL_SR_CHECK_PERIOD          = 5
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name     = "pgpool"
        port     = "postgres"
        provider = "consul"
        tags     = ["postgresql", "load-balancer"]

        check {
          name     = "pgpool-tcp-check"
          type     = "tcp"
          interval = "10s"
          timeout  = "5s"
        }
      }
    }
  }
}