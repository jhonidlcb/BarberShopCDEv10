
#!/bin/bash

echo "🚀 INICIANDO BARBERÍA SISTEMA EN PRODUCCIÓN"
echo "==========================================="

# Verificar si PM2 está instalado
if ! command -v pm2 &> /dev/null; then
    echo "📦 PM2 no está instalado. Instalando..."
    npm install -g pm2
fi

# Verificar si el proyecto está construido
if [ ! -d "dist" ]; then
    echo "🏗️  Construyendo proyecto..."
    npm run build
fi

# Detener procesos anteriores si existen
pm2 delete barberia 2>/dev/null || true

# Iniciar con PM2
echo "🚀 Iniciando con PM2..."
pm2 start dist/index.js --name "barberia" --env production

# Configurar PM2 para auto-inicio
pm2 save
pm2 startup

echo ""
echo "✅ SISTEMA INICIADO EN PRODUCCIÓN"
echo "================================="
echo ""
echo "Comandos útiles:"
echo "pm2 status          - Ver estado"
echo "pm2 logs barberia   - Ver logs"
echo "pm2 restart barberia - Reiniciar"
echo "pm2 stop barberia   - Detener"
echo "pm2 delete barberia - Eliminar"
echo ""
