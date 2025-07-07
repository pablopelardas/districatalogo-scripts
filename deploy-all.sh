#!/bin/bash

echo "🚀 Desplegando todas las aplicaciones..."
echo ""

# Hacer ejecutables los scripts si no lo son
chmod +x deploy-api.sh deploy-backoffice.sh deploy-catalogo.sh

# Ejecutar cada script
/home/pablo/working/distri/scripts/deploy-api.sh
echo ""
/home/pablo/working/distri/scripts/deploy-backoffice.sh
echo ""
/home/pablo/working/distri/scripts/deploy-catalogo.sh

echo ""
echo "✅ Todas las aplicaciones subidas!"
