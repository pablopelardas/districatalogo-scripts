#!/bin/bash

echo "🔄 Sistema de Rollback DistriCatalogo"
echo "====================================="
echo ""
echo "¿Qué aplicación deseas restaurar?"
echo ""
echo "1) API .NET"
echo "2) Backoffice (Nuxt)"
echo "3) Catálogo Público (Vue)"
echo "4) Ver todos los backups disponibles"
echo "5) Limpiar backups antiguos (más de 30 días)"
echo "0) Salir"
echo ""

read -p "Selecciona una opción (0-5): " option

case $option in
    1)
        ./rollback-api.sh
        ;;
    2)
        ./rollback-backoffice.sh
        ;;
    3)
        ./rollback-catalogo.sh
        ;;
    4)
        echo "📋 Backups disponibles:"
        echo ""
        echo "API:"
        ls -lh /var/www/backups/api/*.tar.gz 2>/dev/null | tail -5 || echo "  No hay backups"
        echo ""
        echo "Backoffice:"
        ls -lh /var/www/backups/backoffice/*.tar.gz 2>/dev/null | tail -5 || echo "  No hay backups"
        echo ""
        echo "Catálogo:"
        ls -lh /var/www/backups/catalogo/*.tar.gz 2>/dev/null | tail -5 || echo "  No hay backups"
        ;;
    5)
        echo "🧹 Limpiando backups antiguos (más de 30 días)..."
        find /var/www/backups -name "*.tar.gz" -mtime +30 -type f -delete
        echo "✅ Limpieza completada"
        ;;
    0)
        echo "👋 Saliendo..."
        exit 0
        ;;
    *)
        echo "❌ Opción no válida"
        exit 1
        ;;
esac
