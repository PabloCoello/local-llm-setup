#!/usr/bin/env python3
"""
Code generation example using the local LLM API.
"""

import os
from openai import OpenAI

API_KEY = os.getenv("LITELLM_MASTER_KEY", "sk-1234")
API_BASE = os.getenv("API_BASE", "http://localhost:4000/v1")

client = OpenAI(api_key=API_KEY, base_url=API_BASE)

def generate_code(prompt, model="deepseek-coder", language="python"):
    """Generate code based on a prompt."""
    system_message = f"You are an expert {language} developer. Generate clean, well-documented code."
    
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system_message},
            {"role": "user", "content": prompt}
        ],
        temperature=0.2,  # Lower temperature for more deterministic code
        max_tokens=2000
    )
    
    return response.choices[0].message.content

def main():
    examples = [
        "Write a Python function to calculate fibonacci numbers recursively",
        "Create a Python class for a binary search tree with insert and search methods",
        "Write a Python function to validate email addresses using regex"
    ]
    
    print("Code Generation Examples")
    print("=" * 70)
    
    for i, prompt in enumerate(examples, 1):
        print(f"\n{i}. Prompt: {prompt}")
        print("-" * 70)
        
        try:
            code = generate_code(prompt)
            print(code)
        except Exception as e:
            print(f"Error: {e}")
        
        print("-" * 70)

if __name__ == "__main__":
    main()
