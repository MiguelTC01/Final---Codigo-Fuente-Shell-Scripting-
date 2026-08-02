#!/bin/bash
# ==============================================================================
# Script: ExamenFinal_MenuPrincipal.sh (v0.3)
# Descripción: Menú principal interactivo (Soporta reporte TXT).
# ==============================================================================

export BACKUP_DIR="/var/backups/sistema"
export LOG_FILE="/var/log/backup.log"
export SCRIPT_DIR=$(pwd)

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script requiere privilegios administrativos. Ejecute con sudo." >&2
    exit 1
fi

while true; do
    clear
    echo "=================================================="
    echo "  SISTEMA DE RESPALDO Y MONITOREO (v0.3)          "
    echo "=================================================="
    echo " 1. Ejecutar Backup de Directorios Clave"
    echo " 2. Mostrar Reporte en Texto Plano"
    echo " 3. Salir"
    echo "=================================================="

    read -p "Seleccione una opción [1-3]: " OPCION

    case $OPCION in
        1)
            echo -e "\nIniciando proceso de respaldo..."
            bash "$SCRIPT_DIR/motor_backup.sh"
            read -p "Presione [Enter] para continuar..."
            ;;
        2)
            bash "$SCRIPT_DIR/reporte_txt.sh"
            read -p "Presione [Enter] para continuar..."
            ;;
        3)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida."
            sleep 1
            ;;
    esac
done