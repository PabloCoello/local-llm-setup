#!/bin/bash

set -e

echo "======================================"
echo "Local LLM Setup - Installation Script"
echo "======================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "Please do not run this script as root"
    exit 1
fi

# Check for required commands
command -v docker >/dev/null 2>&1 || { echo "Error: docker is required but not installed. Please install Docker first."; exit 1; }
command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1 || { echo "Error: docker-compose is required but not installed."; exit 1; }

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    
    # Generate random master key
    RANDOM_KEY="sk-$(openssl rand -hex 32)"
    sed -i.bak "s|LITELLM_MASTER_KEY=.*|LITELLM_MASTER_KEY=$RANDOM_KEY|" .env
    
    # Generate random password
    RANDOM_PASSWORD="$(openssl rand -base64 24)"
    sed -i.bak "s|NGINX_PASSWORD=.*|NGINX_PASSWORD=$RANDOM_PASSWORD|" .env
    
    # Clean up backup files
    rm -f .env.bak
    
    echo "✓ Generated random API key and password"
    echo "⚠️  IMPORTANT: Save these credentials securely!"
else
    echo "⚠️  .env file already exists - keeping existing configuration"
fi

# Source .env file
set -a
source .env
set +a

# Validate critical environment variables
if [ -z "$LITELLM_MASTER_KEY" ] || [ "$LITELLM_MASTER_KEY" = "sk-1234-change-me-to-secure-key" ]; then
    echo "❌ ERROR: LITELLM_MASTER_KEY is not set or uses default insecure value"
    echo "Please edit .env file and set a secure random key"
    exit 1
fi

# Check if NGINX_PASSWORD is empty or unset
if [ -z "$NGINX_PASSWORD" ]; then
    echo "❌ ERROR: NGINX_PASSWORD is not set in .env file"
    echo "Please edit .env file and set a secure password"
    exit 1
fi

if [ "$NGINX_PASSWORD" = "change-me-secure-password" ]; then
    echo "⚠️  WARNING: NGINX_PASSWORD uses default value. Generating random password..."
    RANDOM_PASSWORD="$(openssl rand -base64 24)"
    sed -i.bak "s|NGINX_PASSWORD=.*|NGINX_PASSWORD=$RANDOM_PASSWORD|" .env
    source .env
    if [ "$NGINX_PASSWORD" = "change-me-secure-password" ]; then
        echo "❌ ERROR: Failed to update NGINX_PASSWORD in .env file."
        echo "Please check .env file and update NGINX_PASSWORD manually."
        exit 1
    fi
fi

# Create SSL certificates
if [ ! -f config/ssl/cert.pem ] || [ ! -f config/ssl/key.pem ]; then
    echo ""
    echo "Generating self-signed SSL certificates..."
    mkdir -p config/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout config/ssl/key.pem \
        -out config/ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
    echo "SSL certificates generated."
fi

# Create .htpasswd file for Nginx basic auth
if [ ! -f config/.htpasswd ]; then
    echo ""
    echo "Creating Nginx authentication file..."
    mkdir -p config
    
    # Check if htpasswd is available
    if command -v htpasswd >/dev/null 2>&1; then
        htpasswd -cb config/.htpasswd "${NGINX_USER:-admin}" "${NGINX_PASSWORD}"
        echo "✓ Authentication file created with htpasswd"
    else
        # Fallback to openssl if htpasswd is not available
        echo "${NGINX_USER:-admin}:$(openssl passwd -apr1 "${NGINX_PASSWORD}")" > config/.htpasswd
        echo "✓ Authentication file created with openssl"
        echo "⚠️  WARNING: htpasswd command not found. Consider installing apache2-utils"
    fi
    
    # Verify file was created successfully
    if [ ! -s config/.htpasswd ]; then
        echo "❌ ERROR: Failed to create .htpasswd file"
        exit 1
    fi
    
    # Set restrictive permissions
    chmod 600 config/.htpasswd
    
    echo "✓ Nginx credentials: User=${NGINX_USER:-admin}"
else
    echo "✓ Authentication file already exists"
fi

# Pull required Docker images
echo ""
echo "Pulling Docker images (this may take a while)..."
docker-compose pull

# Start services
echo ""
echo "Starting services..."
docker-compose up -d

# Wait for Ollama to be ready
echo ""
echo "Waiting for Ollama to start..."
sleep 10

# Pull initial models
echo ""
echo "Would you like to download initial LLM models?"
echo "Recommended for RTX 3090 (24GB VRAM):"
echo "  1. deepseek-coder:33b (Code generation, ~20GB)"
echo "  2. codellama:34b (Code generation, ~20GB)"
echo "  3. qwen2.5-coder:32b (Code generation, ~20GB)"
echo "  4. mistral:latest (General purpose, ~4GB)"
echo "  5. Skip for now"
echo ""
read -p "Enter your choice (1-5): " model_choice

case $model_choice in
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
        echo "Pulling mistral:latest..."
        docker exec ollama ollama pull mistral:latest
        ;;
    5)
        echo "Skipping model download."
        ;;
    *)
        echo "Invalid choice. Skipping model download."
        ;;
esac

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "Services are running:"
echo "  - Ollama: http://localhost:11434"
echo "  - LiteLLM API: http://localhost:4000"
echo "  - Nginx Proxy (HTTPS): https://localhost"
echo "  - Nginx Proxy (Internal): http://localhost:8080"
echo ""
echo "API Key: $LITELLM_MASTER_KEY"
echo ""
echo "To download additional models:"
echo "  docker exec ollama ollama pull <model-name>"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f"
echo ""
echo "To stop services:"
echo "  docker-compose down"
echo ""
echo "Next steps:"
echo "  1. Review and update .env file with your settings"
echo "  2. Configure your VSCode Continue extension (see vscode-continue-config.json)"
echo "  3. Set up port forwarding on your router for external access (optional)"
echo ""
