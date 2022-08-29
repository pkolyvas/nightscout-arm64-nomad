# Nightscout Nomad Job

This is a nomad job template for running the [Nightscout](https://nightscout.github.io) Continuous Glucose Monitor (CGM). I hope it serves as an example for anyone looking to use containerized Nightscout with the Hashi stack.

I've included a separate nomad job for Mongo in case you need it.

## Sources

By default this uses @dhermann's docker image: https://hub.docker.com/r/dhermanns/rpi-nightscout

You can also use my own docker image: https://hub.docker.com/r/eyeoh/rpi-nightscout

## Requirements:
  - MongoDB
  - Nomad
  - Consul
  - Reverse proxy for TLS termination

## Note to those wishing to run without Consul

You can easily modify the nomad jobs to use Nomad's simplified service discovery capability. An alternate version of each has been supplied here. 


