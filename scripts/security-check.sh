#!/bin/bash

# Security Check Script
# This script verifies that all security measures are in place

set -e

echo "======================================"
echo "   Security Configuration Check"
echo "======================================"
echo ""

ERRORS=0
WARNINGS=0

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
    ERRORS=$((ERRORS + 1))
}

warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Check 1: .env file exists
echo "Checking .env file..."
if [ ! -f .env ]; then
    error ".env file does not exist. Run ./setup.sh first"
else
    set +e
    source .env
    ENV_STATUS=$?
    set -e
    if [ $ENV_STATUS -ne 0 ]; then
        error "Failed to source .env file. Please check for syntax errors or invalid commands."
    else
        success ".env file exists"
    
        # Check 2: API key is not default
        if [ -z "$LITELLM_MASTER_KEY" ]; then
            error "LITELLM_MASTER_KEY is not set in .env"
        elif [ "$LITELLM_MASTER_KEY" = "sk-1234-change-me-to-secure-key" ] || [ "$LITELLM_MASTER_KEY" = "sk-1234" ]; then
            error "LITELLM_MASTER_KEY is using default insecure value!"
            echo "  Generate a new key with: openssl rand -hex 32"
        elif [ ${#LITELLM_MASTER_KEY} -lt 20 ]; then
            warning "LITELLM_MASTER_KEY seems too short (< 20 chars)"
        else
            success "LITELLM_MASTER_KEY is set and appears secure"
        fi
        
        # Check 3: Nginx password is not default
        if [ -z "$NGINX_PASSWORD" ]; then
            error "NGINX_PASSWORD is not set in .env"
        elif [ "$NGINX_PASSWORD" = "change-me-secure-password" ] || [ "$NGINX_PASSWORD" = "admin" ]; then
            error "NGINX_PASSWORD is using default insecure value!"
        elif [ ${#NGINX_PASSWORD} -lt 12 ]; then
            warning "NGINX_PASSWORD seems too short (< 12 chars)"
        else
            success "NGINX_PASSWORD is set and appears secure"
        fi
    fi
fi

echo ""
echo "Checking configuration files..."

# Check 4: .htpasswd exists
if [ ! -f config/.htpasswd ]; then
    error "config/.htpasswd does not exist. Nginx authentication will fail!"
    echo "  Run ./setup.sh to create it"
elif [ ! -s config/.htpasswd ]; then
    error "config/.htpasswd is empty!"
else
    success "config/.htpasswd exists and has content"
fi

# Check 5: SSL certificates exist
if [ ! -f config/ssl/cert.pem ] || [ ! -f config/ssl/key.pem ]; then
    error "SSL certificates not found in config/ssl/"
    echo "  Run ./setup.sh to generate self-signed certificates"
    echo "  For production, use Let's Encrypt: certbot certonly --standalone"
else
    success "SSL certificates exist"
    
    # Check if certificates are expired or expiring soon
    if command -v openssl >/dev/null 2>&1; then
        # Check if certificate has expired
        if ! openssl x509 -checkend 0 -noout -in config/ssl/cert.pem 2>/dev/null; then
            warning "SSL certificate has expired!"
        # Check if certificate expires in less than 30 days (2592000 seconds)
        elif ! openssl x509 -checkend 2592000 -noout -in config/ssl/cert.pem 2>/dev/null; then
            warning "SSL certificate expires in less than 30 days"
        else
            success "SSL certificate is valid"
        fi
    fi
fi

echo ""
echo "Checking docker-compose.yml..."

# Check 6: Ports are bound to localhost
if grep -E -q '(^|\s)['\''"]?11434:11434['\''"]?' docker-compose.yml; then
    error "Ollama port 11434 is exposed to 0.0.0.0 (all interfaces)"
    echo "  Change to: \"127.0.0.1:11434:11434\""
elif grep -E -q '(^|\s)['\''"]?127\.0\.0\.1:11434:11434['\''"]?' docker-compose.yml; then
    success "Ollama port is bound to localhost only"
else
    warning "Could not verify Ollama port binding"
fi

if grep -E -q '(^|\s)['\''"]?4000:4000['\''"]?' docker-compose.yml; then
    error "LiteLLM port 4000 is exposed to 0.0.0.0 (all interfaces)"
    echo "  Change to: \"127.0.0.1:4000:4000\""
elif grep -E -q '(^|\s)['\''"]?127\.0\.0\.1:4000:4000['\''"]?' docker-compose.yml; then
    success "LiteLLM port is bound to localhost only"
else
    warning "Could not verify LiteLLM port binding"
fi

# Check 7: No default fallback in docker-compose
if grep -q 'LITELLM_MASTER_KEY:-sk-1234' docker-compose.yml; then
    error "docker-compose.yml has insecure default fallback for API key"
    echo "  Remove ':-sk-1234' from LITELLM_MASTER_KEY line"
else
    success "No insecure default in docker-compose.yml"
fi

# Check 8: OLLAMA_ORIGINS is not wildcard
if grep -q 'OLLAMA_ORIGINS=\*' docker-compose.yml; then
    warning "OLLAMA_ORIGINS accepts all origins (*)"
    echo "  Consider restricting to specific origins"
else
    success "OLLAMA_ORIGINS appears to be restricted"
fi

echo ""
echo "Checking nginx configuration..."

# Check 9: CORS is not fully open
if grep -q "Access-Control-Allow-Origin.*'\*'" config/nginx.conf; then
    warning "CORS allows all origins (*) in nginx.conf"
    echo "  Consider restricting to specific origins"
else
    success "CORS appears to be restricted"
fi

# Check 10: Rate limiting is enabled
if grep -q "limit_req_zone" config/nginx.conf && grep -q "limit_req " config/nginx.conf; then
    success "Rate limiting is configured"
else
    warning "Rate limiting may not be configured properly"
fi

# Check 11: Basic auth is enabled
if grep -q "auth_basic " config/nginx.conf && grep -q "auth_basic_user_file" config/nginx.conf; then
    success "Basic authentication is configured in nginx"
else
    error "Basic authentication is not configured in nginx.conf"
fi

echo ""
echo "Checking running services..."

# Check 12: Docker services are running
if command -v docker >/dev/null 2>&1; then
    if docker ps | grep -q ollama; then
        success "Ollama container is running"
        
        # Check if GPU is being used
        if docker exec ollama nvidia-smi >/dev/null 2>&1; then
            success "GPU is accessible in Ollama container"
        else
            warning "GPU may not be accessible in Ollama container"
        fi
    else
        warning "Ollama container is not running"
    fi
    
    if docker ps | grep -q litellm; then
        success "LiteLLM container is running"
    else
        warning "LiteLLM container is not running"
    fi
    
    if docker ps | grep -q nginx-proxy; then
        success "Nginx container is running"
    else
        warning "Nginx container is not running"
    fi
else
    warning "Docker command not found, skipping service checks"
fi

echo ""
echo "Checking firewall (if UFW is installed)..."

# Check 13: Firewall status
if command -v ufw >/dev/null 2>&1; then
    if sudo -n true 2>/dev/null; then
        if sudo ufw status 2>/dev/null | grep -q "Status: active"; then
            success "UFW firewall is active"
            
            # Check if dangerous ports are blocked
            if sudo ufw status 2>/dev/null | grep -q "11434.*ALLOW"; then
                error "Port 11434 (Ollama) is allowed in firewall"
                echo "  Block it with: sudo ufw deny 11434"
            fi
            
            if sudo ufw status 2>/dev/null | grep -q "4000.*ALLOW"; then
                error "Port 4000 (LiteLLM) is allowed in firewall"
                echo "  Block it with: sudo ufw deny 4000"
            fi
            
            if sudo ufw status 2>/dev/null | grep -q "443.*ALLOW"; then
                success "Port 443 (HTTPS) is allowed"
            else
                warning "Port 443 (HTTPS) is not allowed in firewall"
                echo "  You may want to allow it: sudo ufw allow 443"
            fi
        else
            warning "UFW firewall is not active"
            echo "  Enable it with: sudo ufw enable"
        fi
    else
        warning "Cannot run sudo non-interactively. Skipping firewall checks."
        echo "  Run this script with sudo access to check firewall status"
    fi
else
    warning "UFW not installed, skipping firewall checks"
fi

echo ""
echo "======================================"
echo "         Summary"
echo "======================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All security checks passed!${NC}"
    echo ""
    echo "Your system appears to be properly secured."
    exit 0
else
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}✗ Found $ERRORS critical error(s)${NC}"
    fi
    
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ Found $WARNINGS warning(s)${NC}"
    fi
    
    echo ""
    echo "Please review and fix the issues above before exposing to internet."
    echo "See SECURITY_CHECKLIST.md for detailed security guidelines."
    
    if [ $ERRORS -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
fi
