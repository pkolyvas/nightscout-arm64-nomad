job "nightscout" {

  datacenters = ["dc1"]
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    # Installing on an RPi can take a while so 5m over 3m to avoid the job being marked unhealthy too quickly
    healthy_deadline = "5m"
    auto_revert = false
    # change this to 0 if you don't want to do canary deploys
    canary = 1
  }

  group "cgm" {
    count = 1
    network {
      # Re-mapped the port because too many projects try to use 1337. 
      port "nightscout" { 
        static = 1338
        to = 1337
      }
    }
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    ephemeral_disk {
      size = 300
    }
    task "nightscout" {
      driver = "docker"
      config {
        # This could easily be swapped for a non-arm64 docker image
        # Ex. `nightscout/cgm-remote-monitor`
        image = "dhermanns/rpi-nightscout:latest"
        ports = ["nightscout"]
      }

      env {
        TZ = "America/Halifax"
        # This expects a mongo service already available
        MONGO_CONNECTION = "mongodb://mongo.service.dc1.consul:27017/nightscout"
        
        # Your admin token
        API_SECRET = "admin_token"
        
        # BG defaults 
        BG_HIGH = "220"
        BG_LOW = "60"
        BG_TARGET_TOP = "180"
        BG_TARGET_BOTTOM = "81"
        
        # I do my TLS termination elsewhere. Set this to false (default) to enable TLS
        INSECURE_USE_HTTP = true
        
        # This option denies access without a token 
        AUTH_DEFAULT_ROLES = "denied"
        
        # Basically all plugins enabled
        ENABLE = "careportal basal dbsize rawbg iob maker bridge cob bwp cage iage sage boluscalc pushover treatmentnotify mmconnect loop pump profile food openaps bage alexa override"
        
        # Dexcom bridge settings
        BRIDGE_USER_NAME = "username" # Not your email address
        BRIDGE_PASSWORD = "password" # Password
        BRIDGE_SERVER = "EU" # Change this to "US" if you're in the USA
      }

      resources {
        cpu    = 500
        memory = 512 
      }
      
      # Basic Health Checks
      service {
        name = "nightscout"
        tags = ["cgm", "monitor", "nightscout" ]
        port = "nightscout"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
