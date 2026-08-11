#!/bin/bash -e

# In case of using HAProxy on the VPS-1 alongside the rails-1 instance, apply this setup:

################################################### HAProxy

# Install
sudo apt update
sudo apt install haproxy

# Copy infrastructure/haproxy/haproxy.prod.cfg to:
sudo nano /etc/haproxy/haproxy.cfg

# Validate
sudo haproxy -c -f /etc/haproxy/haproxy.cfg

# Start
sudo systemctl enable --now haproxy
sudo systemctl restart haproxy

# Check
sudo systemctl status haproxy
curl http://localhost/up

################################################### SSL

# Install
sudo apt install certbot

# Then configure your DNS, make sure your DNS already points:
# example.com → VPS #1 public IP

sudo systemctl stop haproxy
sudo certbot certonly --standalone -d example.com

# Create HAProxy PEM
sudo mkdir -p /etc/haproxy/certs

sudo sh -c 'cat \
  /etc/letsencrypt/live/example.com/fullchain.pem \
  /etc/letsencrypt/live/example.com/privkey.pem \
  > /etc/haproxy/certs/example.com.pem'

sudo chmod 600 /etc/haproxy/certs/example.com.pem

# Start HAProxy
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl enable --now haproxy
sudo systemctl restart haproxy

# Check
curl -I https://example.com

# Automatic certificate renewal
systemctl list-timers | grep certbot
sudo certbot renew --dry-run

# HAProxy needs to get the new certificate loaded
sudo nano /etc/letsencrypt/renewal-hooks/deploy/reload-haproxy.sh
  #!/bin/sh

  # DOMAIN="example.com"

  # cat \
  #   "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" \
  #   "/etc/letsencrypt/live/$DOMAIN/privkey.pem" \
  #   > "/etc/haproxy/certs/$DOMAIN.pem"

  # chmod 600 "/etc/haproxy/certs/$DOMAIN.pem"

  # systemctl reload haproxy

sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-haproxy.sh

# One thing to verify on VPS #2: Kamal Proxy must actually be reachable on port 80 from VPS #1.
# If you have a firewall, allow TCP/80 from VPS #1's private IP, rather than exposing it publicly.

# Before restarting:
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl reload haproxy
