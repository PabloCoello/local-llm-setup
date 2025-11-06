#!/usr/bin/env node
/**
 * Simple chat example using the local LLM API.
 * Run with: node chat_example.js
 */

import OpenAI from 'openai';
import * as readline from 'readline';

const API_KEY = process.env.LITELLM_MASTER_KEY || 'sk-1234';
const API_BASE = process.env.API_BASE || 'http://localhost:4000/v1';

const client = new OpenAI({
  apiKey: API_KEY,
  baseURL: API_BASE
});

async function chat(message, model = 'deepseek-coder') {
  const response = await client.chat.completions.create({
    model: model,
    messages: [
      {role: 'system', content: 'You are a helpful coding assistant.'},
      {role: 'user', content: message}
    ],
    temperature: 0.7,
    max_tokens: 1000
  });
  
  return response.choices[0].message.content;
}

async function main() {
  console.log('Local LLM Chat Example');
  console.log('='.repeat(50));
  console.log(`Using API: ${API_BASE}`);
  console.log("Type 'exit' to quit\n");
  
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  
  const askQuestion = () => {
    rl.question('You: ', async (input) => {
      const userInput = input.trim();
      
      if (['exit', 'quit', 'q'].includes(userInput.toLowerCase())) {
        console.log('Goodbye!');
        rl.close();
        return;
      }
      
      if (!userInput) {
        askQuestion();
        return;
      }
      
      try {
        const response = await chat(userInput);
        console.log(`\nAssistant: ${response}\n`);
      } catch (error) {
        console.log(`\nError: ${error.message}\n`);
      }
      
      askQuestion();
    });
  };
  
  askQuestion();
}

main();
