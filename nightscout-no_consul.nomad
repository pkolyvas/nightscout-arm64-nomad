job "nightscout" {

  datacenters = ["shiftfocus-central"]
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "20s"
    healthy_deadline = "5m"
    auto_revert = false
  }

  group "cgm" {
    count = 1
    network {
      port "nightscout" { 
        static = 3000
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
        image = "dhermanns/rpi-nightscout:latest"
        ports = ["nightscout"]
      }

      env {
        TZ = "America/Halifax"
        # This expects a mongo service already available
        # Change replace me to your instance's domain (but do not make the port available outside the instance)
        # In other words, do not create a security group (in AWS) or add an allow rule for your instance firewall
        MONGO_CONNECTION = "mongodb://replace_me:27017/nightscout"
        
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

      service {
        name = "nightscout"
        tags = ["cgm", "monitor", "nightscout" ]
        provider = "nomad"
        port = "nightscout"
        # check {
        #   name     = "alive"
        #   type     = "tcp"
        #   interval = "10s"
        #   timeout  = "2s"
        # }
      }
    }
  }
}
