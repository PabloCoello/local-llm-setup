#!/usr/bin/env python3
"""
Streaming response example using the local LLM API.
"""

import os
from openai import OpenAI

API_KEY = os.getenv("LITELLM_MASTER_KEY", "sk-1234")
API_BASE = os.getenv("API_BASE", "http://localhost:4000/v1")

client = OpenAI(api_key=API_KEY, base_url=API_BASE)

def stream_response(prompt, model="deepseek-coder"):
    """Stream a response token by token."""
    stream = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        temperature=0.7,
        max_tokens=1000,
        stream=True
    )
    
    for chunk in stream:
        if chunk.choices[0].delta.content:
            yield chunk.choices[0].delta.content

def main():
    prompt = "Write a detailed explanation of how Python decorators work with examples"
    
    print("Streaming Response Example")
    print("=" * 70)
    print(f"Prompt: {prompt}")
    print("-" * 70)
    print()
    
    try:
        for token in stream_response(prompt):
            print(token, end='', flush=True)
        print("\n")
    except Exception as e:
        print(f"\nError: {e}")

if __name__ == "__main__":
    main()
