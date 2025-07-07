#!/bin/bash
set -e

APP_DIR="/var/www/api-districatalogo"
BACKUP_DIR="/var/www/backups/api"

echo "🔄 Rollback de API..."

# Listar backups disponibles
echo "📋 Backups disponibles:"
ls -lt "$BACKUP_DIR"/backup-*.tar.gz | head -10 | nl

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

# Crear backup del estado actual antes de rollback
echo "💾 Creando backup del estado actual..."
CURRENT_BACKUP="$BACKUP_DIR/pre-rollback-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$CURRENT_BACKUP" -C "$APP_DIR" --exclude="appsettings*.json" --exclude="logs" .

# Detener servicio
echo "🛑 Deteniendo servicio..."
sudo systemctl stop districatalogo-api || sudo killall -9 dotnet 2>/dev/null || true

# Limpiar y restaurar
echo "📦 Restaurando archivos..."
# Mantener configuración actual
mv "$APP_DIR"/appsettings*.json /tmp/ 2>/dev/null || true

# Limpiar directorio
find "$APP_DIR" -mindepth 1 -not -path "*/logs*" -delete 2>/dev/null || true

# Extraer backup
tar -xzf "$BACKUP_FILE" -C "$APP_DIR"

# Restaurar configuración
mv /tmp/appsettings*.json "$APP_DIR"/ 2>/dev/null || true

# Permisos
sudo chown -R www-data:www-data "$APP_DIR"
sudo chmod -R 755 "$APP_DIR"
sudo chmod 600 "$APP_DIR"/appsettings*.json

# Reiniciar
echo "🚀 Reiniciando servicio..."
sudo systemctl daemon-reload
sudo systemctl start districatalogo-api

# Verificar
sleep 3
if systemctl is-active --quiet districatalogo-api; then
    echo "✅ Rollback completado exitosamente"
    echo "💾 Backup del estado anterior guardado en: $CURRENT_BACKUP"
else
    echo "❌ Error al iniciar la API después del rollback"
    sudo journalctl -u districatalogo-api -n 20
fi
