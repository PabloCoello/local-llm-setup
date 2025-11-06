# API Usage Guide

This guide explains how to use the LLM API through various methods and programming languages.

## Table of Contents
- [API Endpoints](#api-endpoints)
- [Authentication](#authentication)
- [OpenAI-Compatible API](#openai-compatible-api)
- [Code Examples](#code-examples)
- [Best Practices](#best-practices)

## API Endpoints

Your LLM setup exposes an OpenAI-compatible API at:

- **Local**: `http://localhost:4000`
- **Local Network**: `http://<your-local-ip>:8080`
- **Internet (HTTPS)**: `https://<your-domain-or-ip>`

### Available Endpoints

- `GET /health` - Health check
- `GET /v1/models` - List available models
- `POST /v1/chat/completions` - Chat completions
- `POST /v1/completions` - Text completions
- `POST /v1/embeddings` - Generate embeddings

## Authentication

All requests (except `/health`) require an API key in the Authorization header:

```bash
Authorization: Bearer YOUR_API_KEY
```

Get your API key from `.env` file:
```bash
cat .env | grep LITELLM_MASTER_KEY
```

## OpenAI-Compatible API

The API is fully compatible with OpenAI's API format, so you can use OpenAI client libraries.

### Chat Completions

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "deepseek-coder",
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful coding assistant."
      },
      {
        "role": "user",
        "content": "Write a Python function to calculate fibonacci numbers."
      }
    ],
    "temperature": 0.7,
    "max_tokens": 1000
  }'
```

### Text Completions

```bash
curl -X POST http://localhost:4000/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "deepseek-coder",
    "prompt": "def fibonacci(n):",
    "max_tokens": 100,
    "temperature": 0.7
  }'
```

### List Models

```bash
curl -X GET http://localhost:4000/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"
```

## Code Examples

### Python

#### Using OpenAI Library

```python
from openai import OpenAI

# Initialize client
client = OpenAI(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:4000/v1"
)

# Chat completion
response = client.chat.completions.create(
    model="deepseek-coder",
    messages=[
        {"role": "system", "content": "You are a helpful coding assistant."},
        {"role": "user", "content": "Write a Python function to reverse a string."}
    ],
    temperature=0.7,
    max_tokens=500
)

print(response.choices[0].message.content)
```

#### Using Requests Library

```python
import requests
import json

url = "http://localhost:4000/v1/chat/completions"
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer YOUR_API_KEY"
}

data = {
    "model": "deepseek-coder",
    "messages": [
        {"role": "user", "content": "Explain Python decorators"}
    ],
    "temperature": 0.7,
    "max_tokens": 500
}

response = requests.post(url, headers=headers, json=data)
result = response.json()

print(result['choices'][0]['message']['content'])
```

#### Streaming Responses

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:4000/v1"
)

stream = client.chat.completions.create(
    model="deepseek-coder",
    messages=[{"role": "user", "content": "Write a hello world in Python"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end='')
```

### JavaScript/Node.js

#### Using OpenAI SDK

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  apiKey: 'YOUR_API_KEY',
  baseURL: 'http://localhost:4000/v1'
});

async function generateCode() {
  const completion = await client.chat.completions.create({
    model: 'deepseek-coder',
    messages: [
      {role: 'system', content: 'You are a helpful coding assistant.'},
      {role: 'user', content: 'Write a JavaScript function to sort an array'}
    ],
    temperature: 0.7,
    max_tokens: 500
  });

  console.log(completion.choices[0].message.content);
}

generateCode();
```

#### Using Fetch

```javascript
async function chat(message) {
  const response = await fetch('http://localhost:4000/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_API_KEY'
    },
    body: JSON.stringify({
      model: 'deepseek-coder',
      messages: [{role: 'user', content: message}],
      temperature: 0.7,
      max_tokens: 500
    })
  });

  const data = await response.json();
  return data.choices[0].message.content;
}

chat('Explain async/await in JavaScript').then(console.log);
```

#### Streaming in Node.js

```javascript
import OpenAI from 'openai';

const client = new OpenAI({
  apiKey: 'YOUR_API_KEY',
  baseURL: 'http://localhost:4000/v1'
});

async function streamResponse() {
  const stream = await client.chat.completions.create({
    model: 'deepseek-coder',
    messages: [{role: 'user', content: 'Write a React component'}],
    stream: true
  });

  for await (const chunk of stream) {
    process.stdout.write(chunk.choices[0]?.delta?.content || '');
  }
}

streamResponse();
```

### cURL Examples

#### Basic Chat

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "deepseek-coder",
    "messages": [
      {"role": "user", "content": "Hello, how are you?"}
    ]
  }'
```

#### With System Message

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "deepseek-coder",
    "messages": [
      {"role": "system", "content": "You are a senior software engineer."},
      {"role": "user", "content": "Review this code: def add(a,b): return a+b"}
    ],
    "temperature": 0.3
  }'
```

#### Streaming Response

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "deepseek-coder",
    "messages": [
      {"role": "user", "content": "Write a haiku about coding"}
    ],
    "stream": true
  }'
```

### Go

```go
package main

import (
    "context"
    "fmt"
    "github.com/sashabaranov/go-openai"
)

func main() {
    config := openai.DefaultConfig("YOUR_API_KEY")
    config.BaseURL = "http://localhost:4000/v1"
    client := openai.NewClientWithConfig(config)

    resp, err := client.CreateChatCompletion(
        context.Background(),
        openai.ChatCompletionRequest{
            Model: "deepseek-coder",
            Messages: []openai.ChatCompletionMessage{
                {
                    Role:    openai.ChatMessageRoleUser,
                    Content: "Write a Go function to reverse a string",
                },
            },
        },
    )

    if err != nil {
        fmt.Printf("Error: %v\n", err)
        return
    }

    fmt.Println(resp.Choices[0].Message.Content)
}
```

### Rust

```rust
use reqwest;
use serde_json::json;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = reqwest::Client::new();
    
    let response = client
        .post("http://localhost:4000/v1/chat/completions")
        .header("Content-Type", "application/json")
        .header("Authorization", "Bearer YOUR_API_KEY")
        .json(&json!({
            "model": "deepseek-coder",
            "messages": [
                {"role": "user", "content": "Write a Rust function to sort a vector"}
            ],
            "temperature": 0.7,
            "max_tokens": 500
        }))
        .send()
        .await?;

    let result: serde_json::Value = response.json().await?;
    println!("{}", result["choices"][0]["message"]["content"]);
    
    Ok(())
}
```

## Best Practices

### 1. Error Handling

Always handle errors gracefully:

```python
from openai import OpenAI
import time

client = OpenAI(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:4000/v1"
)

def generate_with_retry(prompt, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = client.chat.completions.create(
                model="deepseek-coder",
                messages=[{"role": "user", "content": prompt}],
                timeout=60
            )
            return response.choices[0].message.content
        except Exception as e:
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)  # Exponential backoff
                continue
            raise e

result = generate_with_retry("Write a Python function")
print(result)
```

### 2. Use Appropriate Temperature

```python
# For code generation (more deterministic)
response = client.chat.completions.create(
    model="deepseek-coder",
    messages=[{"role": "user", "content": "Write a sorting algorithm"}],
    temperature=0.2  # Low temperature
)

# For creative writing (more varied)
response = client.chat.completions.create(
    model="mistral",
    messages=[{"role": "user", "content": "Write a story"}],
    temperature=0.9  # High temperature
)
```

### 3. Limit Token Usage

```python
response = client.chat.completions.create(
    model="deepseek-coder",
    messages=[{"role": "user", "content": "Explain Python"}],
    max_tokens=500,  # Limit response length
    stop=["\n\n", "###"]  # Stop at specific sequences
)
```

### 4. Use System Messages

```python
response = client.chat.completions.create(
    model="deepseek-coder",
    messages=[
        {
            "role": "system",
            "content": "You are an expert Python developer. Provide concise, well-documented code."
        },
        {
            "role": "user",
            "content": "Write a function to validate email addresses"
        }
    ]
)
```

### 5. Batch Requests

```python
import asyncio
from openai import AsyncOpenAI

async_client = AsyncOpenAI(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:4000/v1"
)

async def generate_multiple(prompts):
    tasks = [
        async_client.chat.completions.create(
            model="deepseek-coder",
            messages=[{"role": "user", "content": prompt}]
        )
        for prompt in prompts
    ]
    
    results = await asyncio.gather(*tasks)
    return [r.choices[0].message.content for r in results]

prompts = [
    "Write a Python function to sort",
    "Write a JavaScript function to filter",
    "Write a Go function to map"
]

results = asyncio.run(generate_multiple(prompts))
```

### 6. Monitor Performance

```python
import time

start_time = time.time()

response = client.chat.completions.create(
    model="deepseek-coder",
    messages=[{"role": "user", "content": "Write code"}]
)

end_time = time.time()
print(f"Response time: {end_time - start_time:.2f}s")
print(f"Tokens used: {response.usage.total_tokens}")
```

## Model Selection Guide

Choose the right model for your task:

| Task | Recommended Model | Temperature | Max Tokens |
|------|------------------|-------------|------------|
| Code generation | deepseek-coder | 0.2-0.3 | 1000-2000 |
| Code completion | deepseek-coder | 0.1-0.2 | 100-500 |
| Code review | qwen-coder | 0.3-0.5 | 1000-2000 |
| Documentation | mistral | 0.5-0.7 | 500-1000 |
| General chat | mistral | 0.7-0.9 | 500-1000 |
| Technical explanation | qwen-coder | 0.5-0.7 | 1000-2000 |

## Rate Limits

Current rate limits (configurable in `config/nginx.conf`):
- 10 requests per second per IP
- Burst of 20 requests
- Maximum 100 parallel requests

To adjust, edit `config/nginx.conf` and restart nginx:
```bash
docker-compose restart nginx
```

## Troubleshooting

### Connection Refused

```python
# Solution: Ensure services are running
# docker-compose ps
```

### Unauthorized (401)

```python
# Solution: Check API key
# Ensure the key matches the one in .env file
```

### Timeout Errors

```python
# Solution: Increase timeout
client = OpenAI(
    api_key="YOUR_API_KEY",
    base_url="http://localhost:4000/v1",
    timeout=120.0  # 2 minutes
)
```

### Model Not Found

```python
# Solution: Check available models
models = client.models.list()
print([m.id for m in models.data])
```

## Next Steps

- [VSCode Setup Guide](VSCODE_SETUP.md)
- [Security Best Practices](SECURITY.md)
- [Model Recommendations](MODELS.md)
