# Quick Start Guide

Get up and running in 5 minutes!

## 1. Prerequisites Check

```bash
# Check Docker
docker --version

# Check NVIDIA GPU
nvidia-smi

# Check NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

If any command fails, see [docs/SETUP.md](docs/SETUP.md) for installation instructions.

## 2. Initial Setup

```bash
# Clone repository
git clone https://github.com/PabloCoello/local-llm-setup.git
cd local-llm-setup

# Run setup (creates .env, SSL certs, starts services)
./setup.sh
```

## 3. Download a Model

```bash
# Recommended for RTX 3090
docker exec ollama ollama pull deepseek-coder:33b
```

This will take 10-30 minutes depending on your internet speed.

## 4. Test It Works

```bash
# Test API
./scripts/test-api.sh
```

You should see a successful response!

## 5. Get Your API Key

```bash
cat .env | grep LITELLM_MASTER_KEY
```

Copy this key - you'll need it for VSCode.

## 6. Configure VSCode (Optional)

1. Install **Continue** extension in VSCode
2. Open Continue settings (click gear icon)
3. Copy config from `vscode-continue-config.json`
4. Replace `sk-1234-change-me-to-secure-key` with your actual API key
5. Save and start coding!

## Quick Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# List models
docker exec ollama ollama list

# Download more models
./scripts/pull-models.sh

# Test API
./scripts/test-api.sh

# Check GPU
docker exec ollama nvidia-smi
```

## Using the API

### Python Example

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_API_KEY_HERE",  # From .env file
    base_url="http://localhost:4000/v1"
)

response = client.chat.completions.create(
    model="deepseek-coder",
    messages=[{"role": "user", "content": "Write a Python hello world"}]
)

print(response.choices[0].message.content)
```

### Curl Example

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY_HERE" \
  -d '{
    "model": "deepseek-coder",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Access From Different Locations

### Same Computer
```
http://localhost:4000
```

### Local Network
```
http://192.168.1.X:8080  # Replace X with your local IP
```

### Internet (After configuring domain/port forwarding)
```
https://your-domain.com
```

## Troubleshooting

### Services not starting?
```bash
docker-compose logs -f
```

### GPU not detected?
```bash
nvidia-smi
docker logs ollama
```

### Model download failed?
```bash
docker exec ollama ollama pull deepseek-coder:33b
```

### API not responding?
```bash
# Check services
docker-compose ps

# Restart
docker-compose restart
```

## Next Steps

- 📖 Read [docs/SETUP.md](docs/SETUP.md) for detailed configuration
- 🔒 Review [docs/SECURITY.md](docs/SECURITY.md) before exposing to internet
- 🤖 Check [docs/MODELS.md](docs/MODELS.md) for model recommendations
- 💻 See [docs/VSCODE_SETUP.md](docs/VSCODE_SETUP.md) for Copilot replacement
- 📝 Browse [docs/API_USAGE.md](docs/API_USAGE.md) for code examples

## Need Help?

- Check the [docs/](docs/) folder for detailed guides
- Review common issues in [docs/SETUP.md#troubleshooting](docs/SETUP.md#troubleshooting)
- Open an issue on GitHub

---

**Happy Coding! 🚀**
