#!/bin/bash
set -e

APP_DIR="/var/www/backoffice-districatalogo"
BACKUP_DIR="/var/www/backups/backoffice"

echo "📦 Actualizando Backoffice..."

# Crear directorio de backup si no existe
mkdir -p "$BACKUP_DIR"

# Hacer backup
if [ -d "$APP_DIR/.output" ]; then
    echo "💾 Creando backup..."
    tar -czf "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz" -C "$APP_DIR" .output/
fi

# Encontrar el archivo más reciente
LATEST_TAR=$(ls -t /tmp/backoffice-nuxt-*.tar.gz 2>/dev/null | head -1)

if [ -z "$LATEST_TAR" ]; then
    echo "❌ No se encontró archivo tar en /tmp/"
    exit 1
fi

echo "📦 Extrayendo: $LATEST_TAR"

# Detener PM2
pm2 stop backoffice-districatalogo 2>/dev/null || echo "⚠️  Proceso no estaba corriendo"

# Limpiar y extraer
rm -rf "$APP_DIR/.output"
tar -xzpf "$LATEST_TAR" -C "$APP_DIR"

# Asegurar permisos
chown -R ubuntu:ubuntu "$APP_DIR/.output" 2>/dev/null || chown -R www-data:www-data "$APP_DIR/.output"

# Reiniciar PM2
cd "$APP_DIR"
pm2 start ecosystem.config.cjs
pm2 save

# Limpiar
rm "$LATEST_TAR"

echo "✅ Backoffice actualizado!"
