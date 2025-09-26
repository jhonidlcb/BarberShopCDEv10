
#!/bin/bash

echo "🚀 INSTALADOR DE BARBERÍA SISTEMA"
echo "=================================="

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor instala Node.js 18 o superior."
    exit 1
fi

# Verificar si npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ npm no está instalado. Por favor instala npm."
    exit 1
fi

echo "✅ Node.js y npm detectados"

# Crear directorio de uploads si no existe
if [ ! -d "uploads" ]; then
    mkdir uploads
    echo "✅ Directorio uploads creado"
fi

# Dar permisos al directorio uploads
chmod 755 uploads
echo "✅ Permisos configurados para uploads"

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencias instaladas correctamente"
else
    echo "❌ Error al instalar dependencias"
    exit 1
fi

# Verificar si existe .env
if [ ! -f ".env" ]; then
    echo "⚠️  Archivo .env no encontrado"
    echo "📝 Copiando .env.example a .env"
    cp .env.example .env
    echo "⚠️  IMPORTANTE: Edita el archivo .env con tus configuraciones antes de continuar"
    echo "   - DATABASE_URL: Tu conexión a PostgreSQL"
    echo "   - GMAIL_USER y GMAIL_PASS: Credenciales de email"
    echo "   - JWT_SECRET y SESSION_SECRET: Secrets seguros"
    echo "   - APP_URL y CORS_ORIGIN: Tu dominio"
    exit 1
fi

echo "✅ Archivo .env encontrado"

# Construir el proyecto
echo "🏗️  Construyendo el proyecto..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Proyecto construido correctamente"
else
    echo "❌ Error al construir el proyecto"
    exit 1
fi

echo ""
echo "🎉 INSTALACIÓN COMPLETADA"
echo "========================="
echo ""
echo "Para iniciar el servidor en producción:"
echo "npm run start"
echo ""
echo "El servidor se ejecutará en el puerto configurado en .env (default: 5000)"
echo ""
echo "📝 RECUERDA:"
echo "   1. Configurar tu servidor web (nginx/apache) para proxy reverso"
echo "   2. Configurar SSL/HTTPS"
echo "   3. Configurar un proceso manager como PM2 para producción"
echo ""
