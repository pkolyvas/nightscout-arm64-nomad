# Nightscout Nomad Job

This is a nomad job template for running the [Nightscout](https://nightscout.github.io) Continuous Glucose Monitor (CGM). I hope it serves as an example for anyone looking to use containerized Nightscout with the HashiStack. 

## Sources

By default this uses my own docker image: https://hub.docker.com/eyeoh/rpi-nightscout

It originally used @dhermann's here: https://github.com/dhermanns/rpi-nightscout

## Requirements:
  - MongoDB
  - Reverse proxy for TLS termination
