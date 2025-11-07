# ✅ Lista de Verificación de Seguridad

## ANTES DE EXPONER A INTERNET

### 🔴 CRÍTICO - Debe estar completo

- [ ] **API Key Segura Generada**
  ```bash
  # Verificar que NO sea la clave por defecto
  grep LITELLM_MASTER_KEY .env
  # NO debe ser: sk-1234-change-me-to-secure-key
  ```

- [ ] **Archivo .htpasswd Creado**
  ```bash
  # Verificar que existe
  ls -la config/.htpasswd
  # Debe tener contenido
  cat config/.htpasswd
  ```

- [ ] **Certificados SSL Válidos**
  ```bash
  # Para producción, usar Let's Encrypt
  ls -la config/ssl/
  # Verificar que cert.pem y key.pem existen
  ```

- [ ] **Puertos Restringidos a Localhost**
  ```bash
  # Verificar en docker-compose.yml
  grep "127.0.0.1:" docker-compose.yml
  # Debe mostrar:
  # - "127.0.0.1:11434:11434"  (Ollama)
  # - "127.0.0.1:4000:4000"    (LiteLLM)
  ```

- [ ] **Firewall Configurado**
  ```bash
  # Solo permitir puerto 443 (HTTPS)
  sudo ufw status
  # Debe mostrar:
  # 443/tcp        ALLOW       Anywhere
  # 22/tcp         ALLOW       Anywhere (SSH)
  ```

### 🟡 IMPORTANTE - Recomendado

- [ ] **Contraseña Nginx Cambiada**
  ```bash
  grep NGINX_PASSWORD .env
  # NO debe ser: change-me-secure-password
  ```

- [ ] **Rate Limiting Configurado**
  ```bash
  # Verificar en config/nginx.conf
  grep "limit_req_zone" config/nginx.conf
  ```

- [ ] **Logs Monitorizados**
  ```bash
  # Revisar logs regularmente
  docker-compose logs -f nginx
  docker-compose logs -f litellm
  ```

- [ ] **Backups Configurados**
  ```bash
  # Backup de configuración
  tar -czf backup-$(date +%Y%m%d).tar.gz .env config/
  ```

### 🟢 OPCIONAL - Seguridad Avanzada

- [ ] **Fail2Ban Instalado**
  ```bash
  sudo systemctl status fail2ban
  ```

- [ ] **VPN o Cloudflare Tunnel**
  - Para máxima seguridad, acceder solo via VPN
  - O usar Cloudflare Tunnel en lugar de puerto 443 directo

- [ ] **Certificados de Producción (Let's Encrypt)**
  ```bash
  sudo certbot certonly --standalone -d tu-dominio.com
  ```

- [ ] **IP Whitelisting**
  ```bash
  # En nginx.conf, agregar:
  allow TU_IP_FIJA;
  deny all;
  ```

---

## 🔍 PRUEBAS DE SEGURIDAD

### Test 1: Verificar que puertos internos NO son accesibles

```bash
# Desde OTRO ordenador en tu red
# Estos comandos DEBEN FALLAR (timeout o conexión rechazada)

# Intentar acceder directamente a Ollama (debe fallar)
curl http://TU_IP:11434/api/tags
# Expected: Connection refused o timeout

# Intentar acceder directamente a LiteLLM (debe fallar)
curl http://TU_IP:4000/v1/models
# Expected: Connection refused o timeout
```

### Test 2: Verificar autenticación Nginx

```bash
# Sin credenciales (debe retornar 401)
curl https://TU_IP/ -k
# Expected: 401 Unauthorized

# Con credenciales incorrectas (debe retornar 401)
curl https://TU_IP/ -k -u admin:wrongpass
# Expected: 401 Unauthorized

# Con credenciales correctas (debe funcionar)
curl https://TU_IP/health -k -u admin:TU_PASSWORD
# Expected: 200 OK
```

### Test 3: Verificar API Key

```bash
# Sin API key (debe retornar 401)
curl https://TU_IP/v1/models -k -u admin:TU_PASSWORD
# Expected: 401 o error de autenticación

# Con API key incorrecta (debe retornar 401)
curl https://TU_IP/v1/models -k \
     -u admin:TU_PASSWORD \
     -H "Authorization: Bearer sk-wrong-key"
# Expected: 401 Unauthorized

# Con API key correcta (debe funcionar)
curl https://TU_IP/v1/models -k \
     -u admin:TU_PASSWORD \
     -H "Authorization: Bearer TU_API_KEY_REAL"
# Expected: Lista de modelos
```

### Test 4: Verificar Rate Limiting

```bash
# Enviar muchas peticiones rápidas
for i in {1..30}; do
  curl -s -o /dev/null -w "%{http_code}\n" \
       https://TU_IP/health -k -u admin:TU_PASSWORD
done
# Expected: Algunos deben retornar 429 (Too Many Requests)
```

---

## 🚨 SEÑALES DE COMPROMISO

Revisa logs regularmente buscando:

### Intentos de acceso no autorizados
```bash
docker exec nginx-proxy grep "401" /var/log/nginx/access.log | tail -20
```

### Múltiples peticiones desde misma IP
```bash
docker exec nginx-proxy awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10
```

### Intentos de acceso a rutas sospechosas
```bash
docker exec nginx-proxy grep -E "(admin|phpmyadmin|wp-admin|\.php|\.asp)" /var/log/nginx/access.log
```

### Errores de API key inválida
```bash
docker-compose logs litellm | grep -i "invalid.*key"
```

---

## 📞 EN CASO DE COMPROMISO

### Acción Inmediata

1. **Detener servicios**
   ```bash
   docker-compose down
   ```

2. **Rotar API key**
   ```bash
   # Generar nueva key
   NEW_KEY="sk-$(openssl rand -hex 32)"
   sed -i.bak "s/LITELLM_MASTER_KEY=.*/LITELLM_MASTER_KEY=$NEW_KEY/" .env
   ```

3. **Cambiar contraseñas**
   ```bash
   # Generar nueva password
   NEW_PASS="$(openssl rand -base64 24)"
   sed -i.bak "s/NGINX_PASSWORD=.*/NGINX_PASSWORD=$NEW_PASS/" .env
   
   # Recrear .htpasswd
   htpasswd -cb config/.htpasswd admin "$NEW_PASS"
   ```

4. **Revisar logs completamente**
   ```bash
   docker-compose logs > incident-logs-$(date +%Y%m%d-%H%M%S).log
   ```

5. **Reiniciar con nueva configuración**
   ```bash
   docker-compose up -d
   ```

---

## 📚 Recursos Adicionales

- [Documentación de Seguridad Completa](docs/SECURITY.md)
- [Guía de Configuración](docs/SETUP.md)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

**Última actualización:** 6 de noviembre de 2025
**Versión:** 1.0
