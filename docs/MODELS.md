# Model Recommendations

This guide helps you choose the best LLM models for your RTX 3090 (24GB VRAM) setup.

## Table of Contents
- [Quick Recommendations](#quick-recommendations)
- [Code Generation Models](#code-generation-models)
- [General Purpose Models](#general-purpose-models)
- [Model Comparison](#model-comparison)
- [Performance Benchmarks](#performance-benchmarks)
- [Memory Requirements](#memory-requirements)

## Quick Recommendations

### Best Overall for RTX 3090
**DeepSeek Coder 33B** (~20GB VRAM)
```bash
docker exec ollama ollama pull deepseek-coder:33b
```
- Excellent code generation quality
- Fits comfortably in 24GB VRAM
- Fast inference speed
- Great for VSCode Copilot replacement

### Best for Fast Autocomplete
**Mistral 7B** (~4GB VRAM)
```bash
docker exec ollama ollama pull mistral:latest
```
- Very fast responses
- Low memory usage
- Good quality for quick completions
- Can run alongside larger models

### Best Context Length
**Qwen 2.5 Coder 32B** (~20GB VRAM)
```bash
docker exec ollama ollama pull qwen2.5-coder:32b
```
- 32K context window
- Excellent code understanding
- Latest model with great performance
- Similar VRAM to DeepSeek Coder

## Code Generation Models

### DeepSeek Coder Series

#### DeepSeek Coder 33B (Recommended)
- **Size**: ~20GB VRAM
- **Context Length**: 16K tokens
- **Best For**: Production code generation
- **Languages**: Python, JavaScript, Java, C++, Go, Rust, etc.
- **Pros**: 
  - Excellent code quality
  - Good at following instructions
  - Understands context well
  - Fast inference
- **Cons**: 
  - Requires significant VRAM
  - Slower than smaller models

```bash
docker exec ollama ollama pull deepseek-coder:33b
```

#### DeepSeek Coder 6.7B (Fast Alternative)
- **Size**: ~4GB VRAM
- **Context Length**: 16K tokens
- **Best For**: Quick completions, autocomplete
- **Pros**:
  - Very fast
  - Low VRAM usage
  - Still good quality
  - Can run with other models
- **Cons**:
  - Lower quality than 33B
  - Less context understanding

```bash
docker exec ollama ollama pull deepseek-coder:6.7b
```

### Qwen Coder Series

#### Qwen 2.5 Coder 32B (Recommended)
- **Size**: ~20GB VRAM
- **Context Length**: 32K tokens
- **Best For**: Large codebase understanding
- **Languages**: 92+ programming languages
- **Pros**:
  - Largest context window
  - Latest model (2024)
  - Excellent code quality
  - Great at refactoring
- **Cons**:
  - Slightly slower than DeepSeek

```bash
docker exec ollama ollama pull qwen2.5-coder:32b
```

#### Qwen 2.5 Coder 7B (Balanced)
- **Size**: ~5GB VRAM
- **Context Length**: 32K tokens
- **Best For**: Balanced speed/quality
- **Pros**:
  - Good context length
  - Fast inference
  - Low VRAM
  - Recent model
- **Cons**:
  - Lower quality than 32B

```bash
docker exec ollama ollama pull qwen2.5-coder:7b
```

### Code Llama Series

#### Code Llama 34B
- **Size**: ~20GB VRAM
- **Context Length**: 16K tokens
- **Best For**: Meta ecosystem, Python
- **Languages**: Focus on Python, also supports others
- **Pros**:
  - From Meta (Facebook)
  - Well-documented
  - Good Python support
  - Regular updates
- **Cons**:
  - Not as specialized as DeepSeek/Qwen
  - Python-centric

```bash
docker exec ollama ollama pull codellama:34b
```

#### Code Llama 13B (Efficient)
- **Size**: ~7GB VRAM
- **Context Length**: 16K tokens
- **Best For**: Resource-constrained setups
- **Pros**:
  - Moderate VRAM usage
  - Good balance
  - Fast
- **Cons**:
  - Lower quality than 34B

```bash
docker exec ollama ollama pull codellama:13b
```

## General Purpose Models

### Mistral Series

#### Mistral 7B (Recommended for Speed)
- **Size**: ~4GB VRAM
- **Context Length**: 8K tokens
- **Best For**: Quick responses, chat, explanations
- **Pros**:
  - Very fast
  - Low VRAM
  - Good general knowledge
  - Great for non-code tasks
- **Cons**:
  - Not specialized for code
  - Shorter context

```bash
docker exec ollama ollama pull mistral:latest
```

#### Mixtral 8x7B (High Quality)
- **Size**: ~26GB VRAM
- **Context Length**: 32K tokens
- **Best For**: Maximum quality (barely fits RTX 3090)
- **Pros**:
  - Highest quality
  - Large context
  - Mixture of Experts architecture
- **Cons**:
  - Uses all VRAM
  - Can't run other models simultaneously
  - Slower inference

```bash
docker exec ollama ollama pull mixtral:8x7b
```

### Llama 3 Series

#### Llama 3 8B
- **Size**: ~5GB VRAM
- **Context Length**: 8K tokens
- **Best For**: General purpose, latest from Meta
- **Pros**:
  - Latest Meta model
  - Good general knowledge
  - Fast
  - Low VRAM
- **Cons**:
  - Not code-specialized
  - Shorter context

```bash
docker exec ollama ollama pull llama3:8b
```

#### Llama 3 70B (Too Large)
- **Size**: ~40GB VRAM
- **Warning**: Does NOT fit in RTX 3090 (24GB)
- Only use if you have multiple GPUs or CPU fallback

## Model Comparison

### Code Generation Quality

| Model | Code Quality | Speed | VRAM | Context | Best For |
|-------|-------------|-------|------|---------|----------|
| DeepSeek Coder 33B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 20GB | 16K | Production code |
| Qwen 2.5 Coder 32B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 20GB | 32K | Large codebases |
| Code Llama 34B | ⭐⭐⭐⭐ | ⭐⭐⭐ | 20GB | 16K | Python projects |
| DeepSeek Coder 6.7B | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 4GB | 16K | Quick completions |
| Code Llama 13B | ⭐⭐⭐ | ⭐⭐⭐⭐ | 7GB | 16K | Balanced |
| Mistral 7B | ⭐⭐ | ⭐⭐⭐⭐⭐ | 4GB | 8K | Fast chat |

### General Purpose Quality

| Model | Quality | Speed | VRAM | Context | Best For |
|-------|---------|-------|------|---------|----------|
| Mixtral 8x7B | ⭐⭐⭐⭐⭐ | ⭐⭐ | 26GB | 32K | Maximum quality |
| Mistral 7B | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 4GB | 8K | Fast general use |
| Llama 3 8B | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | 5GB | 8K | Latest general |

## Performance Benchmarks

Approximate performance on RTX 3090:

### Tokens Per Second

| Model | Tokens/sec | First Token Latency |
|-------|-----------|---------------------|
| Mistral 7B | ~80-100 | ~200ms |
| DeepSeek Coder 6.7B | ~70-90 | ~250ms |
| Llama 3 8B | ~60-80 | ~300ms |
| Code Llama 13B | ~40-60 | ~400ms |
| DeepSeek Coder 33B | ~20-30 | ~800ms |
| Qwen 2.5 Coder 32B | ~20-30 | ~800ms |
| Code Llama 34B | ~18-25 | ~900ms |
| Mixtral 8x7B | ~12-18 | ~1200ms |

*Note: Actual performance varies based on prompt length and system configuration*

## Memory Requirements

### VRAM Usage by Model

| Model | VRAM Required | Can Run Together |
|-------|--------------|------------------|
| Mistral 7B | ~4GB | Yes, with most models |
| DeepSeek Coder 6.7B | ~4GB | Yes, with most models |
| Llama 3 8B | ~5GB | Yes, with most models |
| Qwen 2.5 Coder 7B | ~5GB | Yes, with most models |
| Code Llama 13B | ~7GB | With smaller models |
| DeepSeek Coder 33B | ~20GB | Alone or with tiny model |
| Qwen 2.5 Coder 32B | ~20GB | Alone or with tiny model |
| Code Llama 34B | ~20GB | Alone or with tiny model |
| Mixtral 8x7B | ~26GB | Alone only |

### Recommended Combinations for RTX 3090

#### Option 1: Quality Code + Fast Chat
```bash
docker exec ollama ollama pull deepseek-coder:33b  # 20GB
docker exec ollama ollama pull mistral:latest      # 4GB (won't run simultaneously)
```
Use DeepSeek for code, switch to Mistral for quick questions.

#### Option 2: Balanced Dual Models
```bash
docker exec ollama ollama pull codellama:13b      # 7GB
docker exec ollama ollama pull qwen2.5-coder:7b   # 5GB
docker exec ollama ollama pull mistral:latest     # 4GB
```
Can run 1-2 simultaneously depending on load.

#### Option 3: Fast Autocomplete Setup
```bash
docker exec ollama ollama pull deepseek-coder:6.7b  # 4GB
docker exec ollama ollama pull mistral:latest       # 4GB
```
Both can run simultaneously for different tasks.

## Use Case Recommendations

### For VSCode Copilot Replacement

**Primary Model**: DeepSeek Coder 33B or Qwen 2.5 Coder 32B
```bash
docker exec ollama ollama pull deepseek-coder:33b
```

**Autocomplete Model**: DeepSeek Coder 6.7B or Mistral 7B
```bash
docker exec ollama ollama pull deepseek-coder:6.7b
```

### For Learning to Code

**Best Choice**: Code Llama 13B (good explanations, not too slow)
```bash
docker exec ollama ollama pull codellama:13b
```

### For Production Code Generation

**Best Choice**: DeepSeek Coder 33B (highest quality)
```bash
docker exec ollama ollama pull deepseek-coder:33b
```

### For Code Review

**Best Choice**: Qwen 2.5 Coder 32B (large context for understanding)
```bash
docker exec ollama ollama pull qwen2.5-coder:32b
```

### For Documentation Writing

**Best Choice**: Mistral 7B (fast, good for text)
```bash
docker exec ollama ollama pull mistral:latest
```

### For Maximum Quality (No Speed Requirement)

**Best Choice**: Mixtral 8x7B
```bash
docker exec ollama ollama pull mixtral:8x7b
```

## Model Management

### Check Downloaded Models

```bash
docker exec ollama ollama list
```

### Remove Models

```bash
docker exec ollama ollama rm model-name
```

### Model Storage Location

Models are stored in Docker volume:
```bash
docker volume inspect local-llm-setup_ollama_data
```

### Backup Models

```bash
# Create backup
docker run --rm -v local-llm-setup_ollama_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/ollama-models-backup.tar.gz /data

# Restore backup
docker run --rm -v local-llm-setup_ollama_data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/ollama-models-backup.tar.gz -C /
```

## Frequently Asked Questions

### Can I run multiple models at once?

Yes, but they must fit in VRAM together. For RTX 3090 (24GB):
- DeepSeek 33B (~20GB) + Nothing else
- Code Llama 13B (~7GB) + Mistral (~4GB) = ~11GB ✓
- Two Mistral models (~8GB total) ✓

### Which model is closest to GPT-4 quality?

Mixtral 8x7B is closest to GPT-4, but it's large (26GB). For code specifically, DeepSeek Coder 33B and Qwen 2.5 Coder 32B are excellent and more practical.

### How do I choose between DeepSeek and Qwen for code?

- **DeepSeek Coder 33B**: Slightly faster, well-established
- **Qwen 2.5 Coder 32B**: Newer, larger context (32K vs 16K), more languages

Both are excellent. Try both and see which you prefer.

### Can I use quantized models to save VRAM?

Ollama automatically uses quantized versions. The VRAM numbers listed are for the quantized versions Ollama provides.

### What about fine-tuning models?

Fine-tuning requires additional setup beyond this guide. Consider using prompt engineering first, which works well for most use cases.

## Next Steps

- [Setup Guide](SETUP.md)
- [VSCode Configuration](VSCODE_SETUP.md)
- [API Usage Guide](API_USAGE.md)
- [Security Best Practices](SECURITY.md)
