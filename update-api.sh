#!/bin/bash
set -e

APP_DIR="/var/www/api-districatalogo"
BACKUP_DIR="/var/www/backups/api"

echo "📦 Actualizando API..."

# Crear directorio de backup si no existe
mkdir -p "$BACKUP_DIR"

# Hacer backup
echo "💾 Creando backup..."
tar -czf "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz" \
    -C "$APP_DIR" \
    --exclude="appsettings*.json" \
    --exclude="*.pdb" \
    --exclude="logs" \
    .

# Encontrar el archivo más reciente
LATEST_TAR=$(ls -t /tmp/api-districatalogo-*.tar.gz 2>/dev/null | head -1)

if [ -z "$LATEST_TAR" ]; then
    echo "❌ No se encontró archivo tar en /tmp/"
    exit 1
fi

echo "📦 Extrayendo: $LATEST_TAR"

# Detener servicio
echo "🛑 Deteniendo servicio API..."
sudo systemctl stop districatalogo-api || {
    echo "⚠️  Forzando detención..."
    sudo killall -9 dotnet 2>/dev/null || true
}

# Esperar que se libere el puerto
sleep 3

# Verificar que el puerto esté libre
if lsof -i:5001 >/dev/null 2>&1; then
    echo "⚠️  Puerto 5001 aún en uso, esperando..."
    sleep 5
fi

# Extraer
echo "📦 Extrayendo archivos nuevos..."
tar -xzf "$LATEST_TAR" -C "$APP_DIR" --exclude="appsettings*.json"

# Permisos
echo "🔐 Aplicando permisos..."
sudo chown -R www-data:www-data "$APP_DIR"
sudo chmod -R 755 "$APP_DIR"
sudo chmod 644 "$APP_DIR"/*.dll
sudo chmod 600 "$APP_DIR"/appsettings*.json

# Verificar configuración
echo "🔍 Verificando configuración..."
if [ -f "$APP_DIR/appsettings.json" ]; then
    echo "✅ appsettings.json existe"
else
    echo "❌ Falta appsettings.json!"
    exit 1
fi

# Reiniciar servicio
echo "🚀 Iniciando servicio API..."
sudo systemctl daemon-reload
sudo systemctl start districatalogo-api &

# Esperar hasta 30 segundos para que inicie
echo "⏳ Esperando que inicie el servicio..."
for i in {1..30}; do
    if systemctl is-active --quiet districatalogo-api; then
        echo "✅ API iniciada correctamente"
        break
    fi
    echo -n "."
    sleep 1
done
echo ""

# Verificar estado final
if systemctl is-active --quiet districatalogo-api; then
    echo "✅ API corriendo"
    # Probar endpoint
    sleep 2
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:5001/api/health | grep -q "200"; then
        echo "✅ API respondiendo correctamente"
    else
        echo "⚠️  API corriendo pero no responde aún"
    fi
else
    echo "❌ Error al iniciar la API"
    sudo journalctl -u districatalogo-api -n 30 --no-pager
fi

# Limpiar
rm "$LATEST_TAR"

echo "✅ Proceso de actualización completado!"
