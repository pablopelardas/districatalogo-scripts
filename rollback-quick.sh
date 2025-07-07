#!/bin/bash
# Script para rollback rápido al último backup

if [ $# -eq 0 ]; then
    echo "Uso: $0 [api|backoffice|catalogo]"
    exit 1
fi

APP=$1
BACKUP_DIR="/var/www/backups/$APP"

# Obtener el último backup
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ No hay backups disponibles para $APP"
    exit 1
fi

echo "🔄 Rollback rápido de $APP"
echo "📦 Usando: $(basename $LATEST_BACKUP)"
echo "📅 Fecha: $(stat -c %y "$LATEST_BACKUP" | cut -d' ' -f1,2)"
echo ""
read -p "¿Continuar? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    case $APP in
        api)
            # Poner el backup seleccionado como el primero para que el script lo tome
            export BACKUP_NUM=1
            ./rollback-api.sh <<< "1
y"
            ;;
        backoffice)
            export BACKUP_NUM=1
            ./rollback-backoffice.sh <<< "1
y"
            ;;
        catalogo)
            export BACKUP_NUM=1
            ./rollback-catalogo.sh <<< "1
y"
            ;;
        *)
            echo "❌ Aplicación no válida: $APP"
            exit 1
            ;;
    esac
else
    echo "❌ Rollback cancelado"
fi
