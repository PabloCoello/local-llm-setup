# Local LLM Setup

Complete Docker-based setup for running state-of-the-art open-source LLMs locally, optimized for **NVIDIA RTX 3090** with secure access from localhost, local network, and internet.

## 🚀 Features

- **State-of-the-Art Models**: Run models like DeepSeek Coder 33B, Qwen Coder 32B, CodeLlama 34B
- **VSCode Integration**: Drop-in replacement for GitHub Copilot using Continue extension
- **Multi-Access**: Access from same computer, local network, and internet
- **Secure by Default**: API key authentication, SSL/TLS, rate limiting, and firewall rules
- **GPU Optimized**: Configured for NVIDIA RTX 3090 (24GB VRAM) with CUDA acceleration
- **OpenAI-Compatible API**: Use with any OpenAI SDK or client library

## 📋 Architecture

```
┌─────────────────────────────────────────────────┐
│  VSCode Continue Extension / API Clients        │
└───────────────┬─────────────────────────────────┘
                │
        ┌───────▼────────┐
        │  Nginx Proxy   │  ← SSL/TLS, Auth, Rate Limiting
        │  (Port 443)    │
        └───────┬────────┘
                │
        ┌───────▼────────┐
        │   LiteLLM      │  ← OpenAI-compatible API
        │  (Port 4000)   │
        └───────┬────────┘
                │
        ┌───────▼────────┐
        │    Ollama      │  ← LLM Runtime (GPU)
        │  (Port 11434)  │
        └────────────────┘
```

## 🎯 Requirements Met

✅ **Run state-of-the-art open LLM models**: DeepSeek Coder 33B, Qwen 32B, CodeLlama 34B, etc.  
✅ **VSCode Copilot alternative**: Full integration with Continue extension  
✅ **Multi-access**: Localhost, LAN, and internet with proper configuration  
✅ **Secure**: API keys, SSL/TLS, Basic Auth, rate limiting, firewall rules  
✅ **RTX 3090 optimized**: GPU acceleration with CUDA, model recommendations for 24GB VRAM

## 🚦 Quick Start

### Prerequisites

- **Hardware**: NVIDIA RTX 3090 (or similar GPU with 16GB+ VRAM)
- **Software**: Docker, Docker Compose, NVIDIA Docker Runtime
- **OS**: Linux (Ubuntu 20.04+) or Windows with WSL2

### Installation

```bash
# Clone the repository
git clone https://github.com/PabloCoello/local-llm-setup.git
cd local-llm-setup

# Run setup script
./setup.sh
```

The setup script will:
1. Create `.env` file with secure random API key
2. Generate SSL certificates
3. Setup authentication
4. Pull Docker images
5. Start all services
6. Guide you through model selection

### Download Models

```bash
# Interactive model downloader
./scripts/pull-models.sh

# Or manually
docker exec ollama ollama pull deepseek-coder:33b
```

### Test Installation

```bash
# Test API connectivity
./scripts/test-api.sh
```

## 📖 Documentation

- **[Setup Guide](docs/SETUP.md)** - Detailed installation and configuration
- **[VSCode Setup](docs/VSCODE_SETUP.md)** - Configure Continue extension as Copilot alternative
- **[Security Guide](docs/SECURITY.md)** - Security best practices and hardening
- **[API Usage](docs/API_USAGE.md)** - Code examples in Python, JavaScript, Go, Rust
- **[Model Guide](docs/MODELS.md)** - Model recommendations and comparisons

## 🔧 Configuration

### Access Points

After setup, access the LLM API through:

| Access Type | URL | Use Case |
|------------|-----|----------|
| Local | `http://localhost:4000` | Same computer |
| LAN | `http://<local-ip>:8080` | Local network |
| Internet | `https://<domain>` | External access |

### Security

Your API key is in `.env` file:
```bash
cat .env | grep LITELLM_MASTER_KEY
```

Use in requests:
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     http://localhost:4000/v1/models
```

## 💻 VSCode Integration

1. Install Continue extension in VSCode
2. Get your API key: `cat .env | grep LITELLM_MASTER_KEY`
3. Copy config from `vscode-continue-config.yaml`
4. Update API key in Continue settings
5. Start coding with AI assistance!

See [VSCode Setup Guide](docs/VSCODE_SETUP.md) for details.

## 🎨 API Usage Examples

### Python

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:4000/v1"
)

response = client.chat.completions.create(
    model="deepseek-coder",
    messages=[
        {"role": "user", "content": "Write a Python function to calculate fibonacci"}
    ]
)

print(response.choices[0].message.content)
```

### JavaScript

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  apiKey: 'YOUR_API_KEY',
  baseURL: 'http://localhost:4000/v1'
});

const response = await client.chat.completions.create({
  model: 'deepseek-coder',
  messages: [{role: 'user', content: 'Write a React component'}]
});

console.log(response.choices[0].message.content);
```

See [API Usage Guide](docs/API_USAGE.md) for more examples.

## 📊 Recommended Models for RTX 3090

| Model | VRAM | Speed | Quality | Best For |
|-------|------|-------|---------|----------|
| DeepSeek Coder 33B | ~20GB | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Production code |
| Qwen 2.5 Coder 32B | ~20GB | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Large codebases |
| CodeLlama 34B | ~20GB | ⭐⭐⭐ | ⭐⭐⭐⭐ | Python projects |
| Mistral 7B | ~4GB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Fast completions |
| DeepSeek Coder 6.7B | ~4GB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Quick autocomplete |

See [Model Guide](docs/MODELS.md) for detailed comparisons.

## 🛠️ Management Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart a service
docker-compose restart ollama

# Download a model
docker exec ollama ollama pull deepseek-coder:33b

# List downloaded models
docker exec ollama ollama list

# Remove a model
docker exec ollama ollama rm model-name

# Check GPU usage
docker exec ollama nvidia-smi
```

## 🔒 Security Features

- **API Key Authentication**: Required for all API calls
- **SSL/TLS Encryption**: HTTPS with configurable certificates
- **Basic Authentication**: Nginx-level username/password
- **Rate Limiting**: 10 req/s per IP with burst protection
- **IP Whitelisting**: Configurable allowed networks
- **Firewall Rules**: UFW configuration included
- **Fail2Ban**: Brute force protection (optional)

See [Security Guide](docs/SECURITY.md) for hardening steps.

## 🐛 Troubleshooting

### GPU Not Detected

```bash
# Check NVIDIA driver
nvidia-smi

# Test NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### Services Not Starting

```bash
# View logs
docker-compose logs -f

# Restart services
docker-compose restart
```

### Out of Memory

Use smaller models:
```bash
docker exec ollama ollama pull mistral:latest  # ~4GB
docker exec ollama ollama pull codellama:13b  # ~7GB
```

See [Setup Guide](docs/SETUP.md#troubleshooting) for more solutions.

## 📁 Project Structure

```
local-llm-setup/
├── docker-compose.yml              # Main Docker composition
├── .env.example                    # Environment variables template
├── setup.sh                        # Installation script
├── config/
│   ├── litellm_config.yaml        # LiteLLM configuration
│   ├── nginx.conf                 # Nginx reverse proxy config
│   └── ssl/                       # SSL certificates
├── scripts/
│   ├── pull-models.sh             # Model downloader
│   └── test-api.sh                # API testing script
├── docs/
│   ├── SETUP.md                   # Setup guide
│   ├── VSCODE_SETUP.md            # VSCode integration
│   ├── SECURITY.md                # Security best practices
│   ├── API_USAGE.md               # API examples
│   └── MODELS.md                  # Model recommendations
└── vscode-continue-config.yaml    # Continue extension config
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Ollama](https://ollama.ai/) - LLM runtime
- [LiteLLM](https://litellm.ai/) - API proxy
- [Continue](https://continue.dev/) - VSCode extension
- [Nginx](https://nginx.org/) - Reverse proxy
- Model creators: DeepSeek, Alibaba Qwen, Meta (Code Llama), Mistral AI

## 📞 Support

- **Documentation**: See [docs/](docs/) folder
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions

---

**Note**: This setup is optimized for development and personal use. For production deployments, review and enhance security measures according to your requirements.
