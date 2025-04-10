job "lightq-backend" {
  datacenters = ["dc1"]
  type        = "service"

  group "backend" {
    count = 1

    network {
      port "http" {
        to = 3000
      }
    }

    #service {
    #  name = "nestjs"
    #  port = "http"

    #check {
    #  type     = "http"
    #  path     = "/health"
    #  interval = "10s"
    #  timeout  = "2s"
    #}
    #}

    task "nestjs" {
      driver = "docker"

      config {
        image = "192.168.10.122/lightq/test-nomad:v1.0.0"
        ports = ["http"]
      }
    }
  }
}
