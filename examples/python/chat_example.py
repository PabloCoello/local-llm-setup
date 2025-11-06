#!/usr/bin/env python3
"""
Simple chat example using the local LLM API.
"""

import os
from openai import OpenAI

# Get API key from environment or use default
API_KEY = os.getenv("LITELLM_MASTER_KEY", "sk-1234")
API_BASE = os.getenv("API_BASE", "http://localhost:4000/v1")

# Initialize client
client = OpenAI(
    api_key=API_KEY,
    base_url=API_BASE
)

def chat(message, model="deepseek-coder"):
    """Send a message to the LLM and get a response."""
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": "You are a helpful coding assistant."},
            {"role": "user", "content": message}
        ],
        temperature=0.7,
        max_tokens=1000
    )
    
    return response.choices[0].message.content

def main():
    print("Local LLM Chat Example")
    print("=" * 50)
    print(f"Using API: {API_BASE}")
    print("Type 'exit' to quit\n")
    
    while True:
        user_input = input("You: ").strip()
        
        if user_input.lower() in ['exit', 'quit', 'q']:
            print("Goodbye!")
            break
            
        if not user_input:
            continue
        
        try:
            response = chat(user_input)
            print(f"\nAssistant: {response}\n")
        except Exception as e:
            print(f"\nError: {e}\n")

if __name__ == "__main__":
    main()
