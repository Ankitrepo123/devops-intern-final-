variable "image_tag" {
  type    = string
  default = "latest"
}

job "nginx-app" {
  datacenters = ["dc1"]
  type        = "service"

  group "nginx" {
    count = 1

    network {
      port "http" {
        to = 8080
      }
    }

    service {
      name = "nginx-app"
      port = "http"

      check {
        name     = "nginx-health"
        type     = "http"
        path     = "/healthz"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 3
      interval = "30m"
      delay    = "15s"
      mode     = "delay"
    }

    reschedule {
      attempts       = 3
      interval       = "30m"
      delay          = "30s"
      delay_function = "exponential"
      max_delay      = "1h"
      unlimited      = false
    }

    update {
      max_parallel      = 1
      min_healthy_time   = "10s"
      healthy_deadline   = "2m"
      auto_revert       = true
      canary             = 0
      progress_deadline = "10m"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "ghcr.io/ankitrepo123/devops-intern-final:${var.image_tag}"

        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
