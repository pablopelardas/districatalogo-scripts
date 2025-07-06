#!/bin/bash

echo "🚀 Desplegando todas las aplicaciones..."
echo ""

# Hacer ejecutables los scripts si no lo son
chmod +x deploy-api.sh deploy-backoffice.sh deploy-catalogo.sh

# Ejecutar cada script
./deploy-api.sh
echo ""
./deploy-backoffice.sh
echo ""
./deploy-catalogo.sh

echo ""
echo "✅ Todas las aplicaciones subidas!"
