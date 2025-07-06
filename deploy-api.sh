#!/bin/bash
set -e

# Configuración
PROJECT_PATH="/mnt/d/working/distri/DistriCatalogoAPI"  # Ajusta esta ruta
SERVER_IP="31.97.173.157"
SERVER_USER="root"
TAR_NAME="api-districatalogo-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "🚀 Desplegando API .NET..."

# Ir al proyecto
cd "$PROJECT_PATH"

# Publicar
echo "📦 Publicando proyecto..."
dotnet publish -c Release -r linux-x64 --self-contained false -o ./publish

# Crear tar
echo "📦 Creando archivo tar..."
cd publish
tar -czf "/tmp/$TAR_NAME" *
cd ..

# Subir al servidor
echo "📤 Subiendo al servidor..."
scp "/tmp/$TAR_NAME" "$SERVER_USER@$SERVER_IP:/tmp/"

# Limpiar local
rm "/tmp/$TAR_NAME"

echo "✅ API subida como: $TAR_NAME"
echo "Ejecuta en el servidor: update-api.sh"
