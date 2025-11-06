# Setup Guide

## Prerequisites

### Hardware Requirements
- **GPU**: NVIDIA RTX 3090 (24GB VRAM) or similar
- **RAM**: 32GB+ recommended
- **Storage**: 100GB+ free space for models
- **CPU**: Multi-core processor (8+ cores recommended)

### Software Requirements
- **Operating System**: Linux (Ubuntu 20.04+ recommended) or Windows with WSL2
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **NVIDIA Docker Runtime**: For GPU acceleration
- **OpenSSL**: For generating SSL certificates

## Installation Steps

### 1. Install Docker and NVIDIA Container Toolkit

#### Ubuntu/Debian
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Test NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### 2. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd local-llm-setup

# Run the setup script
./setup.sh
```

The setup script will:
- Create `.env` file with secure random API key
- Generate self-signed SSL certificates
- Create Nginx authentication credentials
- Pull Docker images
- Start all services
- Optionally download initial LLM models

### 3. Verify Installation

Check that all services are running:
```bash
docker-compose ps
```

You should see three services running:
- `ollama` - LLM runtime
- `litellm` - API proxy
- `nginx-proxy` - Reverse proxy

### 4. Download Models

Use the model downloader script:
```bash
./scripts/pull-models.sh
```

**Recommended models for RTX 3090:**
- `deepseek-coder:33b` (~20GB) - Best for code generation
- `qwen2.5-coder:32b` (~20GB) - Excellent code model
- `mistral:latest` (~4GB) - Fast general purpose

### 5. Test API

Run the test script to verify everything works:
```bash
./scripts/test-api.sh
```

## Access Points

After setup, you can access the LLM API through:

### 1. Direct Access (Same Computer)
```
http://localhost:4000
```

### 2. Internal Network Access
```
http://localhost:8080
http://<your-local-ip>:8080
```

### 3. External Access (HTTPS with Authentication)
```
https://localhost
https://<your-local-ip>
https://<your-domain> (if configured)
```

## Security Configuration

### API Key Authentication

Your API key is stored in `.env` file:
```bash
cat .env | grep LITELLM_MASTER_KEY
```

Use this key in API requests:
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     http://localhost:4000/v1/models
```

### HTTPS/TLS

The setup script creates self-signed certificates for development. For production:

1. **Use Let's Encrypt (Recommended)**:
```bash
# Install certbot
sudo apt-get install certbot

# Get certificate
sudo certbot certonly --standalone -d your-domain.com

# Update .env
SSL_CERT_PATH=/etc/letsencrypt/live/your-domain.com/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/your-domain.com/privkey.pem
```

2. **Update docker-compose.yml** to mount the certificates:
```yaml
nginx:
  volumes:
    - /etc/letsencrypt:/etc/letsencrypt:ro
```

### Basic Authentication

Change the default Nginx credentials in `.env`:
```bash
NGINX_USER=your-username
NGINX_PASSWORD=your-secure-password
```

Regenerate the `.htpasswd` file:
```bash
htpasswd -c config/.htpasswd your-username
docker-compose restart nginx
```

### Firewall Configuration

For external access, configure your firewall:

```bash
# Allow HTTPS (443)
sudo ufw allow 443/tcp

# Allow HTTP (80) for Let's Encrypt
sudo ufw allow 80/tcp

# Block direct access to internal ports (optional)
sudo ufw deny 4000/tcp
sudo ufw deny 11434/tcp
```

### Router Port Forwarding

For internet access:
1. Log into your router
2. Forward port 443 to your machine's local IP
3. Optionally forward port 80 for Let's Encrypt

## Troubleshooting

### GPU Not Detected

```bash
# Check NVIDIA driver
nvidia-smi

# Test NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi

# Check Ollama GPU usage
docker logs ollama
```

### Services Not Starting

```bash
# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Rebuild if needed
docker-compose down
docker-compose up -d --build
```

### Out of Memory Errors

If you see OOM errors:
1. Use smaller models (e.g., `mistral:latest`, `codellama:13b`)
2. Reduce concurrent requests in `config/litellm_config.yaml`
3. Increase system swap space

### Connection Issues

```bash
# Test local connectivity
curl http://localhost:11434
curl http://localhost:4000/health

# Check if ports are listening
netstat -tulpn | grep -E '(443|4000|11434)'

# Test from another machine on local network
curl http://<your-local-ip>:8080/health
```

## Performance Optimization

### GPU Memory Management

Edit `docker-compose.yml` to limit GPU memory:
```yaml
ollama:
  environment:
    - OLLAMA_GPU_MEMORY_FRACTION=0.9
```

### Model Loading

Keep frequently used models loaded:
```bash
# Pre-load a model
docker exec ollama ollama run deepseek-coder:33b "Hello"
```

### Concurrent Requests

Adjust in `config/litellm_config.yaml`:
```yaml
general_settings:
  max_parallel_requests: 100  # Reduce if needed
```

## Next Steps

- [Configure VSCode Continue Extension](VSCODE_SETUP.md)
- [API Usage Guide](API_USAGE.md)
- [Security Best Practices](SECURITY.md)
- [Model Recommendations](MODELS.md)
