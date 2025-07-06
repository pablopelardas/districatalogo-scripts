#!/bin/bash
set -e

APP_DIR="/var/www/catalogo-districatalogo"
BACKUP_DIR="/var/www/backups/catalogo"

echo "📦 Actualizando Catálogo..."

# Crear directorio de backup si no existe
mkdir -p "$BACKUP_DIR"

# Hacer backup
if [ -d "$APP_DIR/dist" ]; then
    echo "💾 Creando backup..."
    tar -czf "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz" -C "$APP_DIR" dist/
fi

# Encontrar el archivo más reciente
LATEST_TAR=$(ls -t /tmp/catalogo-vue-*.tar.gz 2>/dev/null | head -1)

if [ -z "$LATEST_TAR" ]; then
    echo "❌ No se encontró archivo tar en /tmp/"
    exit 1
fi

echo "📦 Extrayendo: $LATEST_TAR"

# Detener PM2
pm2 stop catalogo-districatalogo || true

# Limpiar y extraer
rm -rf "$APP_DIR/dist"
tar -xzf "$LATEST_TAR" -C "$APP_DIR"

# Instalar dependencias si es necesario
cd "$APP_DIR"
npm install --production

# Reiniciar PM2
pm2 start ecosystem.config.cjs
pm2 save

# Limpiar
rm "$LATEST_TAR"

echo "✅ Catálogo actualizado!"
