#!/usr/bin/env node
/**
 * Streaming response example using the local LLM API.
 * Run with: node streaming_example.js
 */

import OpenAI from 'openai';

const API_KEY = process.env.LITELLM_MASTER_KEY || 'sk-1234';
const API_BASE = process.env.API_BASE || 'http://localhost:4000/v1';

const client = new OpenAI({
  apiKey: API_KEY,
  baseURL: API_BASE
});

async function streamResponse(prompt, model = 'deepseek-coder') {
  const stream = await client.chat.completions.create({
    model: model,
    messages: [{role: 'user', content: prompt}],
    temperature: 0.7,
    max_tokens: 1000,
    stream: true
  });
  
  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content;
    if (content) {
      process.stdout.write(content);
    }
  }
  
  console.log('\n');
}

async function main() {
  const prompt = 'Write a detailed explanation of how JavaScript async/await works with examples';
  
  console.log('Streaming Response Example');
  console.log('='.repeat(70));
  console.log(`Prompt: ${prompt}`);
  console.log('-'.repeat(70));
  console.log();
  
  try {
    await streamResponse(prompt);
  } catch (error) {
    console.log(`\nError: ${error.message}`);
  }
}

main();
