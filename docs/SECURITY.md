# Security Best Practices

This document outlines security measures and best practices for running your local LLM setup.

## Table of Contents
- [Multi-Layer Security Architecture](#multi-layer-security-architecture)
- [API Key Security](#api-key-security)
- [Network Security](#network-security)
- [SSL/TLS Configuration](#ssltls-configuration)
- [Authentication](#authentication)
- [Firewall Rules](#firewall-rules)
- [Rate Limiting](#rate-limiting)
- [Monitoring and Logging](#monitoring-and-logging)
- [Security Checklist](#security-checklist)

## Multi-Layer Security Architecture

The setup implements multiple layers of security:

```
Internet
   ↓
[Router/Firewall] ← Port forwarding (443 only)
   ↓
[Host Firewall (ufw)] ← Allow only necessary ports
   ↓
[Nginx Reverse Proxy] ← SSL/TLS, Basic Auth, Rate Limiting
   ↓
[LiteLLM] ← API Key authentication
   ↓
[Ollama] ← Local only (not exposed)
```

## API Key Security

### 1. Generate Strong API Keys

Always use cryptographically secure random keys:

```bash
# Generate a new secure API key
openssl rand -hex 32
```

Update in `.env`:
```bash
LITELLM_MASTER_KEY=sk-your-secure-random-key-here
```

### 2. Rotate API Keys Regularly

Rotate your API keys every 3-6 months:

```bash
# Generate new key
NEW_KEY="sk-$(openssl rand -hex 32)"

# Update .env
sed -i "s/LITELLM_MASTER_KEY=.*/LITELLM_MASTER_KEY=$NEW_KEY/" .env

# Restart services
docker-compose restart litellm

# Update clients (VSCode, scripts, etc.) with new key
```

### 3. Never Commit API Keys

The `.env` file is in `.gitignore`, but double-check:

```bash
# Verify .env is ignored
git check-ignore .env

# If not, add it
echo ".env" >> .gitignore
```

### 4. Use Different Keys for Different Purposes

Create multiple keys for different use cases:

```yaml
# In config/litellm_config.yaml
general_settings:
  master_key: ${LITELLM_MASTER_KEY}
  
  # Optional: Define multiple API keys with different permissions
  api_keys:
    - key: sk-vscode-key
      permissions: ["chat", "completions"]
    - key: sk-admin-key
      permissions: ["chat", "completions", "models", "admin"]
```

## Network Security

### 1. Local Access Only (Most Secure)

For maximum security, only allow localhost access:

```yaml
# In docker-compose.yml
litellm:
  ports:
    - "127.0.0.1:4000:4000"  # Only localhost
```

### 2. Local Network Access

Allow access from your local network only:

```nginx
# In config/nginx.conf
server {
    listen 8080;
    
    # Allow only from local network
    allow 127.0.0.0/8;
    allow 10.0.0.0/8;
    allow 172.16.0.0/12;
    allow 192.168.0.0/16;
    deny all;
}
```

### 3. Internet Access (Use with Caution)

If you need internet access:

1. **Use a VPN** (Recommended):
```bash
# Install WireGuard
sudo apt install wireguard

# Configure VPN
# Only allow access through VPN
```

2. **Use Cloudflare Tunnel** (Alternative):
```bash
# Install cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Create tunnel
cloudflared tunnel create llm-tunnel

# Route traffic
cloudflared tunnel route dns llm-tunnel llm.yourdomain.com
```

## SSL/TLS Configuration

### 1. Use Let's Encrypt for Production

```bash
# Install certbot
sudo apt-get install certbot

# Get certificate
sudo certbot certonly --standalone -d your-domain.com

# Update docker-compose.yml
nginx:
  volumes:
    - /etc/letsencrypt/live/your-domain.com/fullchain.pem:/etc/nginx/ssl/cert.pem:ro
    - /etc/letsencrypt/live/your-domain.com/privkey.pem:/etc/nginx/ssl/key.pem:ro
```

### 2. Auto-Renewal

```bash
# Add cron job for renewal
sudo crontab -e

# Add line:
0 0 * * 0 certbot renew --quiet && docker-compose restart nginx
```

### 3. Strong TLS Configuration

Update `config/nginx.conf`:

```nginx
# Use only TLS 1.3 (most secure)
ssl_protocols TLSv1.3;

# Strong cipher suites
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;

# Enable HSTS
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
```

## Authentication

### 1. Nginx Basic Authentication

Change default credentials immediately:

```bash
# Create strong password
NEW_PASSWORD=$(openssl rand -base64 32)

# Update .htpasswd
htpasswd -cb config/.htpasswd admin "$NEW_PASSWORD"

# Save password securely
echo "Nginx Password: $NEW_PASSWORD" >> ~/.local-llm-passwords.txt
chmod 600 ~/.local-llm-passwords.txt

# Restart nginx
docker-compose restart nginx
```

### 2. Two-Factor Authentication (Advanced)

For enhanced security, add 2FA using Nginx with PAM:

```nginx
# Install nginx-auth-pam module
# Configure PAM for 2FA
# This requires custom nginx build
```

### 3. IP Whitelisting

Restrict access to known IP addresses:

```nginx
# In config/nginx.conf
location / {
    # Allow specific IPs only
    allow 203.0.113.0;    # Your home IP
    allow 198.51.100.0;   # Your office IP
    deny all;
    
    # Rest of config...
}
```

## Firewall Rules

### 1. UFW (Ubuntu Firewall)

```bash
# Reset firewall (careful!)
sudo ufw --force reset

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (important!)
sudo ufw allow 22/tcp

# Allow HTTPS only
sudo ufw allow 443/tcp

# Allow HTTP for Let's Encrypt (optional)
sudo ufw allow 80/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status verbose
```

### 2. Block Direct Access to Services

```bash
# Block direct access to Ollama
sudo ufw deny 11434/tcp

# Block direct access to LiteLLM
sudo ufw deny 4000/tcp

# Only allow through Nginx
sudo ufw allow from 172.16.0.0/12 to any port 4000 proto tcp
```

### 3. Fail2Ban (Brute Force Protection)

```bash
# Install fail2ban
sudo apt-get install fail2ban

# Create nginx filter
sudo nano /etc/fail2ban/filter.d/nginx-auth.conf
```

```ini
[Definition]
failregex = ^ \[error\] \d+#\d+: \*\d+ user "\S+":? (password mismatch|was not found in), client: <HOST>
ignoreregex =
```

```bash
# Configure jail
sudo nano /etc/fail2ban/jail.local
```

```ini
[nginx-auth]
enabled = true
filter = nginx-auth
port = https,http
logpath = /var/log/nginx/error.log
maxretry = 3
bantime = 3600
findtime = 600
```

```bash
# Restart fail2ban
sudo systemctl restart fail2ban
```

## Rate Limiting

### 1. Nginx Rate Limiting

Already configured in `config/nginx.conf`:

```nginx
# Rate limiting zones
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

location / {
    # Rate limiting (10 requests per second, burst of 20)
    limit_req zone=api_limit burst=20 nodelay;
}
```

Adjust based on your needs:

```nginx
# Stricter limits
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=5r/s;
limit_req zone=api_limit burst=10 nodelay;

# More permissive limits
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=20r/s;
limit_req zone=api_limit burst=50 nodelay;
```

### 2. LiteLLM Rate Limiting

Configure in `config/litellm_config.yaml`:

```yaml
general_settings:
  # Limit parallel requests
  max_parallel_requests: 10
  
  # Budget limits per user
  max_user_budget: 10.0  # Dollar equivalent
```

## Monitoring and Logging

### 1. Enable Logging

```bash
# View real-time logs
docker-compose logs -f

# Save logs to file
docker-compose logs > /var/log/llm-setup.log

# Nginx access logs
docker exec nginx-proxy cat /var/log/nginx/access.log

# Check for suspicious activity
docker exec nginx-proxy tail -f /var/log/nginx/access.log | grep -E "(POST|DELETE|PUT)"
```

### 2. Monitor Failed Authentication Attempts

```bash
# Check for 401 errors (unauthorized)
docker exec nginx-proxy grep "401" /var/log/nginx/access.log | tail -20

# Check for 403 errors (forbidden)
docker exec nginx-proxy grep "403" /var/log/nginx/access.log | tail -20
```

### 3. Set Up Alerts

```bash
# Install logwatch
sudo apt-get install logwatch

# Configure email alerts
sudo nano /etc/cron.daily/00logwatch
```

## Security Checklist

Before exposing your LLM setup to the internet:

- [ ] Changed default API key to a strong random key
- [ ] Changed default Nginx credentials
- [ ] Configured SSL/TLS with valid certificates
- [ ] Enabled firewall (UFW or similar)
- [ ] Blocked direct access to Ollama and LiteLLM ports
- [ ] Configured rate limiting
- [ ] Set up fail2ban for brute force protection
- [ ] Enabled logging and monitoring
- [ ] Tested all access points
- [ ] Documented all credentials securely
- [ ] Set up backup system
- [ ] Configured automatic security updates
- [ ] Reviewed and understood all security measures

### Regular Security Maintenance

- [ ] Rotate API keys every 3-6 months
- [ ] Update Docker images monthly
- [ ] Review logs weekly
- [ ] Update SSL certificates (auto with Let's Encrypt)
- [ ] Review firewall rules quarterly
- [ ] Audit access patterns monthly
- [ ] Test backup/restore procedures quarterly

## Emergency Procedures

### If API Key is Compromised

```bash
# 1. Immediately generate new key
NEW_KEY="sk-$(openssl rand -hex 32)"

# 2. Update .env
echo "LITELLM_MASTER_KEY=$NEW_KEY" > .env

# 3. Restart services
docker-compose restart litellm

# 4. Update all clients
# - VSCode Continue config
# - Scripts
# - Other applications

# 5. Review logs for suspicious activity
docker-compose logs litellm | grep -i error
```

### If System is Compromised

```bash
# 1. Immediately shut down services
docker-compose down

# 2. Block all incoming connections
sudo ufw deny in

# 3. Investigate
# Check logs, running processes, network connections

# 4. If necessary, restore from backup
# 5. Update all credentials
# 6. Apply security patches
```

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Nginx Security Guide](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

## Next Steps

- [Setup Guide](SETUP.md)
- [VSCode Configuration](VSCODE_SETUP.md)
- [API Usage Guide](API_USAGE.md)
