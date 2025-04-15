job "postgresql-standalone" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgresql1" {
    network {
      mode = "host"
      port "postgresql" {
        static = 5432
      }
    }

    task "postgresql" {
      driver = "docker"

      config {
        image      = "postgres:latest"
        ports      = ["postgresql"]
        force_pull = false

        volumes = [
          "postgres_data:/var/lib/postgresql/data:rw"
        ]

        volume_driver = "local"
      }

      env {
        POSTGRES_PASSWORD = "tu_password_seguro"
        POSTGRES_USER     = "postgres"
        POSTGRES_DB       = "postgres"
      }

      resources {
        cpu    = 1000
        memory = 2048
      }

      service {
        name = "postgresql1"
        port = "postgresql"
        tags = ["postgresql", "database"]

        check {
          name     = "pg-tcp-check"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
