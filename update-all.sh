#!/bin/bash

echo "🚀 Actualizando todas las aplicaciones..."
echo ""

# Hacer ejecutables los scripts si no lo son
chmod +x update-api.sh update-backoffice.sh update-catalogo.sh

# Verificar qué archivos hay disponibles
echo "📦 Archivos disponibles en /tmp:"
ls -la /tmp/*.tar.gz 2>/dev/null || echo "No hay archivos tar.gz"
echo ""

# Preguntar qué actualizar
read -p "¿Actualizar API? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./update-api.sh
fi

read -p "¿Actualizar Backoffice? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./update-backoffice.sh
fi

read -p "¿Actualizar Catálogo? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./update-catalogo.sh
fi

echo ""
echo "✅ Actualización completada!"
