#!/bin/bash
set -e

APP_DIR="/var/www/backoffice-districatalogo"
BACKUP_DIR="/var/www/backups/backoffice"

echo "🔄 Rollback de Backoffice..."

# Listar backups disponibles
echo "📋 Backups disponibles:"
ls -lt "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | head -10 | nl

if [ $(ls -1 "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | wc -l) -eq 0 ]; then
    echo "❌ No hay backups disponibles"
    exit 1
fi

# Pedir al usuario que seleccione
read -p "Selecciona el número del backup a restaurar (1-10): " BACKUP_NUM

# Obtener el archivo seleccionado
BACKUP_FILE=$(ls -lt "$BACKUP_DIR"/backup-*.tar.gz | head -10 | sed -n "${BACKUP_NUM}p" | awk '{print $9}')

if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup no válido"
    exit 1
fi

echo "📦 Restaurando desde: $(basename $BACKUP_FILE)"
read -p "¿Estás seguro? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Rollback cancelado"
    exit 1
fi

# Crear backup del estado actual
echo "💾 Creando backup del estado actual..."
if [ -d "$APP_DIR/.output" ]; then
    tar -czf "$BACKUP_DIR/pre-rollback-$(date +%Y%m%d-%H%M%S).tar.gz" -C "$APP_DIR" .output/
fi

# Detener PM2
echo "🛑 Deteniendo aplicación..."
pm2 stop backoffice-districatalogo 2>/dev/null || true

# Restaurar
echo "📦 Restaurando archivos..."
rm -rf "$APP_DIR/.output"
tar -xzpf "$BACKUP_FILE" -C "$APP_DIR"

# Permisos
chown -R ubuntu:ubuntu "$APP_DIR/.output" 2>/dev/null || chown -R www-data:www-data "$APP_DIR/.output"

# Reiniciar
echo "🚀 Reiniciando aplicación..."
cd "$APP_DIR"
pm2 start ecosystem.config.cjs
pm2 save

echo "✅ Rollback completado exitosamente"
