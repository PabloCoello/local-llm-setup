# API Examples

This directory contains example code showing how to use the local LLM API.

## Python Examples

Located in `python/` directory:

- **chat_example.py** - Interactive chat interface
- **code_generation.py** - Generate code from prompts
- **streaming_example.py** - Stream responses in real-time

### Setup

```bash
# Install dependencies
pip install openai

# Set your API key (or use default)
export LITELLM_MASTER_KEY="your-api-key-here"

# Run examples
python examples/python/chat_example.py
python examples/python/code_generation.py
python examples/python/streaming_example.py
```

## JavaScript Examples

Located in `javascript/` directory:

- **chat_example.js** - Interactive chat interface
- **streaming_example.js** - Stream responses in real-time

### Setup

```bash
# Install dependencies
cd examples/javascript
npm install

# Set your API key (or use default)
export LITELLM_MASTER_KEY="your-api-key-here"

# Run examples
npm run chat
npm run stream

# Or directly
node chat_example.js
node streaming_example.js
```

## Go Examples

Located in `go/` directory:

Coming soon!

## Common Tasks

### Get Your API Key

```bash
cat .env | grep LITELLM_MASTER_KEY
```

### Test Connection

```bash
curl http://localhost:4000/health
```

### List Available Models

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     http://localhost:4000/v1/models
```

## Customization

All examples can be customized by setting environment variables:

```bash
# API endpoint
export API_BASE="http://localhost:4000/v1"

# API key
export LITELLM_MASTER_KEY="sk-your-key"

# Model to use (optional)
export MODEL_NAME="deepseek-coder"
```

## More Examples

For more detailed examples and use cases, see:
- [API Usage Guide](../docs/API_USAGE.md)
- [VSCode Setup](../docs/VSCODE_SETUP.md)

## Troubleshooting

### Connection refused

Make sure services are running:
```bash
docker-compose ps
```

### Unauthorized

Check your API key matches the one in `.env` file:
```bash
cat .env | grep LITELLM_MASTER_KEY
```

### Model not found

List available models:
```bash
docker exec ollama ollama list
```

Download a model:
```bash
docker exec ollama ollama pull deepseek-coder:33b
```
