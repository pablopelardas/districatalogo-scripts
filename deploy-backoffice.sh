#!/bin/bash
set -e

# Configuración
PROJECT_PATH="/home/pablo/working/distri/districatalogo-manager"  # Ajusta esta ruta
SERVER_IP="31.97.173.157"
SERVER_USER="root"
TAR_NAME="backoffice-nuxt-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "🚀 Desplegando Backoffice..."

# Ir al proyecto
cd "$PROJECT_PATH"

# Build
echo "📦 Compilando proyecto..."
NODE_ENV=production npm run build

# Crear tar con flags correctas para Nuxt
echo "📦 Creando archivo tar..."
tar -czphf "/tmp/$TAR_NAME" .output/ package*.json

# Subir al servidor
echo "📤 Subiendo al servidor..."
scp "/tmp/$TAR_NAME" "$SERVER_USER@$SERVER_IP:/tmp/"

# Limpiar local
rm "/tmp/$TAR_NAME"

echo "✅ Backoffice subido como: $TAR_NAME"
echo "Ejecuta en el servidor: update-backoffice.sh"
