# VSCode Continue Extension Setup

This guide explains how to configure VSCode Continue extension to work with your local LLM setup as a Copilot alternative.

## What is Continue?

Continue is an open-source AI code assistant extension for VSCode that provides:
- Code completions (similar to GitHub Copilot)
- Chat interface for code questions
- Code refactoring and generation
- Support for custom LLM backends

## Installation

1. Open VSCode
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "Continue"
4. Install the "Continue - Codestral, Claude, and more" extension
5. Restart VSCode

## Configuration

### Step 1: Open Continue Configuration

1. Click on the Continue icon in the left sidebar
2. Click the gear icon (⚙️) in the Continue panel
3. This opens `~/.continue/config.yaml`

### Step 2: Configure Your Local LLM

Replace the contents of `config.yaml` with the configuration from `vscode-continue-config.yaml` in this repository.

**Important**: Update the `apiKey` fields with your actual API key from the `.env` file:

```bash
# Get your API key
cat .env | grep LITELLM_MASTER_KEY
```

### Step 3: Update API Base URL

For **local development** (same computer):
```yaml
apiBase: http://localhost:4000
```

For **local network access**:
```yaml
apiBase: http://<your-local-ip>:8080
```

For **internet access**:
```yaml
apiBase: https://<your-domain-or-ip>
```

### Complete Configuration Example

```yaml
models:
  - title: DeepSeek Coder 33B
    provider: openai
    model: deepseek-coder
    apiBase: http://localhost:4000
    apiKey: sk-your-actual-api-key-here
    contextLength: 16384
    completionOptions:
      temperature: 0.2
      topP: 0.95
      presencePenalty: 0.0
      frequencyPenalty: 0.0

  - title: Qwen Coder 32B
    provider: openai
    model: qwen-coder
    apiBase: http://localhost:4000
    apiKey: sk-your-actual-api-key-here
    contextLength: 32768
    completionOptions:
      temperature: 0.2
      topP: 0.95

  - title: Mistral (Fast)
    provider: openai
    model: mistral
    apiBase: http://localhost:4000
    apiKey: sk-your-actual-api-key-here
    contextLength: 8192
    completionOptions:
      temperature: 0.7
      topP: 0.95

tabAutocompleteModel:
  title: DeepSeek Coder 33B (Autocomplete)
  provider: openai
  model: deepseek-coder
  apiBase: http://localhost:4000
  apiKey: sk-your-actual-api-key-here

customCommands:
  - name: test
    prompt: Write a comprehensive test suite for the selected code
  - name: doc
    prompt: Write detailed documentation for the selected code
  - name: optimize
    prompt: Suggest optimizations for the selected code
  - name: explain
    prompt: Explain what the selected code does in detail

allowAnonymousTelemetry: false
```

## Usage

### Code Completions

1. Start typing code
2. Continue will automatically suggest completions
3. Press `Tab` to accept suggestions
4. Press `Esc` to dismiss

### Chat Interface

1. Click the Continue icon in the left sidebar
2. Type your question or request in the chat
3. Select code and reference it with `@code`
4. Reference files with `@file`

### Keyboard Shortcuts

- `Ctrl+I` (or `Cmd+I` on Mac): Open Continue chat
- `Ctrl+Shift+R`: Refactor selected code
- `Ctrl+Shift+L`: Explain selected code
- `Tab`: Accept autocomplete suggestion

### Custom Commands

Use `/` in the chat to access custom commands:
- `/test` - Generate tests for selected code
- `/doc` - Generate documentation
- `/optimize` - Suggest optimizations
- `/explain` - Explain code in detail
- `/edit` - Edit selected code
- `/comment` - Add comments to code
- `/commit` - Generate commit message

## Model Selection

Choose different models based on your needs:

### For Code Completions (Fast)
Use `deepseek-coder:6.7b` or `mistral:latest` for faster autocomplete:

```yaml
tabAutocompleteModel:
  model: mistral
  apiBase: http://localhost:4000
  apiKey: sk-your-api-key
```

### For Code Generation (Quality)
Use `deepseek-coder:33b` or `qwen2.5-coder:32b` for high-quality code:

```yaml
models:
  - model: deepseek-coder
    apiBase: http://localhost:4000
```

### For General Questions
Use `mistral:latest` for faster responses:

```yaml
models:
  - model: mistral
    apiBase: http://localhost:4000
```

## Performance Tips

### 1. Download Smaller Models for Autocomplete

For faster tab completions:
```bash
docker exec ollama ollama pull deepseek-coder:6.7b
```

Update Continue config:
```yaml
tabAutocompleteModel:
  model: deepseek-coder:6.7b
```

### 2. Adjust Temperature

Lower temperature for more deterministic code:
```yaml
completionOptions:
  temperature: 0.1  # More deterministic
```

Higher temperature for more creative code:
```yaml
completionOptions:
  temperature: 0.8  # More creative
```

### 3. Context Length

Reduce context length for faster responses:
```yaml
contextLength: 4096  # Instead of 16384
```

### 4. Disable Autocomplete if Too Slow

In Continue settings, you can disable tab autocomplete and only use the chat interface.

## Troubleshooting

### Autocomplete Not Working

1. Check if LLM services are running:
```bash
docker-compose ps
```

2. Test API manually:
```bash
./scripts/test-api.sh
```

3. Check Continue extension logs:
   - Open VSCode Output panel (Ctrl+Shift+U)
   - Select "Continue" from dropdown

### Slow Responses

1. Use a smaller/faster model:
```bash
docker exec ollama ollama pull mistral:latest
```

2. Reduce context length in config
3. Ensure GPU is being used:
```bash
docker logs ollama | grep -i gpu
```

### Connection Errors

1. Verify API base URL is correct
2. Check if firewall is blocking the port
3. Verify API key is correct
4. Test with curl:
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     http://localhost:4000/v1/models
```

### Authentication Errors

1. Ensure API key in Continue config matches `.env` file
2. Regenerate API key if needed:
```bash
# Edit .env file
nano .env

# Restart services
docker-compose restart litellm
```

## Advanced Configuration

### Multiple Model Profiles

Create different profiles for different tasks:

```yaml
models:
  - title: Fast (Autocomplete)
    model: mistral
    completionOptions:
      temperature: 0.1
      maxTokens: 100

  - title: Quality (Code Review)
    model: deepseek-coder
    completionOptions:
      temperature: 0.3
      maxTokens: 2000

  - title: Creative (Brainstorming)
    model: qwen-coder
    completionOptions:
      temperature: 0.9
      maxTokens: 1000
```

### Context Providers

Enable additional context sources:

```yaml
contextProviders:
  - name: code
    params: {}
  - name: diff
    params: {}
  - name: terminal
    params: {}
  - name: problems
    params: {}
  - name: folder
    params: {}
  - name: codebase
    params: {}
```

## Comparison with GitHub Copilot

| Feature | GitHub Copilot | Continue + Local LLM |
|---------|---------------|---------------------|
| Cost | $10-20/month | Free (after hardware) |
| Privacy | Code sent to cloud | 100% local |
| Speed | Fast | Depends on hardware |
| Quality | High | High (with good models) |
| Customization | Limited | Full control |
| Models | Fixed | Any model you want |
| Offline | No | Yes |

## Next Steps

- [Model Recommendations](MODELS.md)
- [API Usage Guide](API_USAGE.md)
- [Performance Optimization](SETUP.md#performance-optimization)
