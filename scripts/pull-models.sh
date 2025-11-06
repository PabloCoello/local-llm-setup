#!/bin/bash

set -e

echo "======================================"
echo "LLM Model Downloader"
echo "======================================"
echo ""
echo "This script helps you download LLM models to Ollama"
echo "Choose models based on your RTX 3090 (24GB VRAM)"
echo ""

# Check if Ollama container is running
if ! docker ps | grep -q ollama; then
    echo "Error: Ollama container is not running."
    echo "Please start services first: docker-compose up -d"
    exit 1
fi

# Display menu
echo "Available Models:"
echo ""
echo "Code Generation Models (Best for VSCode Copilot Alternative):"
echo "  1.  deepseek-coder:33b      (~20GB) - Excellent for code, fits RTX 3090"
echo "  2.  codellama:34b            (~20GB) - Meta's code specialist"
echo "  3.  qwen2.5-coder:32b        (~20GB) - Latest Qwen coder"
echo "  4.  codellama:13b            (~7GB)  - Smaller, faster"
echo "  5.  deepseek-coder:6.7b      (~4GB)  - Very fast, good quality"
echo ""
echo "General Purpose Models:"
echo "  6.  mistral:latest           (~4GB)  - Fast, good quality"
echo "  7.  mixtral:8x7b             (~26GB) - Highest quality, barely fits"
echo "  8.  llama3:8b                (~5GB)  - Latest Meta model"
echo "  9.  llama3:70b               (~40GB) - Too large for single RTX 3090"
echo "  10. phi3:medium              (~8GB)  - Microsoft's efficient model"
echo ""
echo "Specialized Models:"
echo "  11. llama3-gradient:70b      (~40GB) - Extended context (too large)"
echo "  12. dolphin-mixtral:8x7b     (~26GB) - Uncensored version"
echo ""
echo "  13. List all downloaded models"
echo "  14. Remove a model"
echo "  15. Exit"
echo ""

read -p "Enter your choice (1-15): " choice

case $choice in
    1)
        echo "Pulling deepseek-coder:33b..."
        docker exec ollama ollama pull deepseek-coder:33b
        ;;
    2)
        echo "Pulling codellama:34b..."
        docker exec ollama ollama pull codellama:34b
        ;;
    3)
        echo "Pulling qwen2.5-coder:32b..."
        docker exec ollama ollama pull qwen2.5-coder:32b
        ;;
    4)
        echo "Pulling codellama:13b..."
        docker exec ollama ollama pull codellama:13b
        ;;
    5)
        echo "Pulling deepseek-coder:6.7b..."
        docker exec ollama ollama pull deepseek-coder:6.7b
        ;;
    6)
        echo "Pulling mistral:latest..."
        docker exec ollama ollama pull mistral:latest
        ;;
    7)
        echo "Pulling mixtral:8x7b (this may take a while)..."
        docker exec ollama ollama pull mixtral:8x7b
        ;;
    8)
        echo "Pulling llama3:8b..."
        docker exec ollama ollama pull llama3:8b
        ;;
    9)
        echo "Warning: llama3:70b requires ~40GB VRAM. Your RTX 3090 has 24GB."
        read -p "Continue anyway? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            docker exec ollama ollama pull llama3:70b
        fi
        ;;
    10)
        echo "Pulling phi3:medium..."
        docker exec ollama ollama pull phi3:medium
        ;;
    11)
        echo "Warning: llama3-gradient:70b requires ~40GB VRAM. Your RTX 3090 has 24GB."
        read -p "Continue anyway? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            docker exec ollama ollama pull llama3-gradient:70b
        fi
        ;;
    12)
        echo "Pulling dolphin-mixtral:8x7b..."
        docker exec ollama ollama pull dolphin-mixtral:8x7b
        ;;
    13)
        echo "Listing downloaded models..."
        docker exec ollama ollama list
        ;;
    14)
        echo "Listing downloaded models..."
        docker exec ollama ollama list
        echo ""
        read -p "Enter model name to remove: " model_name
        docker exec ollama ollama rm "$model_name"
        ;;
    15)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

echo ""
echo "Done!"
echo ""
echo "Current models:"
docker exec ollama ollama list
