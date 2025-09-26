
# 🏪 GUÍA DE INSTALACIÓN - SISTEMA BARBERÍA

## 📋 Requisitos Previos

### Servidor
- **Ubuntu/Debian/CentOS** (recomendado)
- **Node.js 18+** y **npm**
- **PostgreSQL** (local o remoto como Neon)
- **Nginx** (para proxy reverso)
- **PM2** (para gestión de procesos)

### Servicios Externos
- **Base de datos PostgreSQL** (ya configurada en Neon)
- **Cuenta Gmail** con contraseña de aplicación

## 🚀 Instalación Rápida

### 1. Descargar y extraer el proyecto
```bash
# Subir archivos al servidor via FTP/SCP
# Extraer en directorio deseado (ej: /var/www/barberia)
cd /var/www/barberia
```

### 2. Ejecutar instalador automático
```bash
chmod +x install.sh
./install.sh
```

### 3. Configurar variables de entorno
```bash
nano .env
```

Editar con tus datos reales:
```env
DATABASE_URL=postgresql://neondb_owner:npg_3n6SRzNgmWaI@ep-still-term-acjgon5c-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
GMAIL_USER=jhonidelacruz89@gmail.com
GMAIL_PASS=htzmerglesqpdoht
JWT_SECRET=tu-secret-super-seguro-aqui
APP_URL=https://tu-dominio.com
CORS_ORIGIN=https://tu-dominio.com
```

### 4. Iniciar en producción
```bash
chmod +x start-production.sh
./start-production.sh
```

## ⚙️ Configuración de Nginx

Crear archivo `/etc/nginx/sites-available/barberia`:

```nginx
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;
    
    # Redirigir HTTP a HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name tu-dominio.com www.tu-dominio.com;
    
    # Configuración SSL (usar Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/tu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/tu-dominio.com/privkey.pem;
    
    # Configuraciones de seguridad SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH;
    ssl_prefer_server_ciphers on;
    
    # Proxy al servidor Node.js
    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Configuración para archivos estáticos
    location /uploads/ {
        alias /var/www/barberia/uploads/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Activar el sitio:
```bash
ln -s /etc/nginx/sites-available/barberia /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

## 🔒 Configurar SSL con Let's Encrypt

```bash
# Instalar Certbot
apt install certbot python3-certbot-nginx

# Obtener certificado
certbot --nginx -d tu-dominio.com -d www.tu-dominio.com

# Configurar renovación automática
crontab -e
# Agregar: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔧 Comandos de Mantenimiento

### Gestión con PM2
```bash
pm2 status              # Ver estado de procesos
pm2 logs barberia       # Ver logs del sistema
pm2 restart barberia    # Reiniciar aplicación
pm2 reload barberia     # Recarga sin downtime
pm2 stop barberia       # Detener aplicación
pm2 start barberia      # Iniciar aplicación
```

### Logs del sistema
```bash
pm2 logs barberia --lines 100    # Ver últimas 100 líneas
pm2 flush barberia               # Limpiar logs
```

### Actualizaciones
```bash
# Detener aplicación
pm2 stop barberia

# Actualizar código
# (subir nuevos archivos)

# Reinstalar dependencias si es necesario
npm install

# Reconstruir
npm run build

# Reiniciar
pm2 restart barberia
```

## 🛡️ Seguridad Adicional

### 1. Firewall
```bash
ufw allow ssh
ufw allow 'Nginx Full'
ufw enable
```

### 2. Backup de Base de Datos
```bash
# Crear script de backup automático
nano /usr/local/bin/backup-barberia.sh
```

### 3. Monitoreo
```bash
# Instalar herramientas de monitoreo
pm2 install pm2-logrotate
pm2 set pm2-logrotate:retain 7
```

## 📞 Soporte

Si tienes problemas durante la instalación:
1. Revisa los logs: `pm2 logs barberia`
2. Verifica la configuración: `cat .env`
3. Prueba la conexión a DB: `npm run db:push`

## 🎯 Verificación Post-Instalación

1. ✅ Sitio web accesible en tu dominio
2. ✅ Panel admin funcional en `/admin`
3. ✅ Envío de emails funcionando
4. ✅ Subida de imágenes funcionando
5. ✅ SSL certificado válido
6. ✅ PM2 proceso corriendo
