job "mongo" {
  datacenters = [
      "dc1"
  ]
  type        = "service"

  update {
    max_parallel      = 1
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "10m"
    auto_revert       = false
    canary            = 0
  }

  migrate {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "database" {
    count = 1

    network {
      port "db" { static = 27017 }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    #ephemeral_disk {
    #  sticky  = true
    #  migrate = true
    #  size    = 32768
    #}

    task "mongo_container" {
      driver = "docker"

      config {
        image = "mongo:3.4"
        ports = ["db"]
        volumes = [
                "/data:/data"
              ]

        extra_hosts = [
          "mylocalhost:${attr.unique.network.ip-address}",
          "nomad-host-ip:${NOMAD_IP_db}",
          "mongo:${NOMAD_IP_db}"
        ]
      }

      #resources {
      #  cpu    = 2000
      #  memory = 1024
      #}

      service {
        name = "mongo"
        port = "db"
        provider = "nomad"
	# Check Removed to remove the necessity of using Consul
  #check {
        #  name         = "http-alive"
        #  type         = "http"
        #  path         = "/"
        #  interval     = "10s"
        #  timeout      = "5s"
        #  port         = 27017
        #  address_mode = "driver"
        #}

        tags = [
          "urlprefix-:27017 proto=tcp"
        ]
      }
    }
  }
}
