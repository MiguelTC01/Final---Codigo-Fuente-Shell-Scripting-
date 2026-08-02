#!/bin/bash
# ==============================================================================
# Script: motor_backup.sh (v0.1)
# Descripción: Motor básico de respaldo y compresión.
# ==============================================================================

BACKUP_DIR="/var/backups/sistema"
LOG_FILE="/var/log/backup.log"
DIRECTORIOS_CLAVE=("/etc" "/var/log")
FECHA=$(date +"%Y%m%d_%H%M%S")
ARCHIVO_DESTINO="${BACKUP_DIR}/backup_infra_${FECHA}.tar.gz"

if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir -p "$BACKUP_DIR"
    chmod 700 "$BACKUP_DIR"
fi

RUTAS_VALIDAS=()
for dir in "${DIRECTORIOS_CLAVE[@]}"; do
    if [[ -d "$dir" ]]; then
        RUTAS_VALIDAS+=("$dir")
    fi
done

if [[ ${#RUTAS_VALIDAS[@]} -gt 0 ]]; then
    tar -czf "$ARCHIVO_DESTINO" "${RUTAS_VALIDAS[@]}" 2>/dev/null
    if [[ $? -eq 0 || $? -eq 1 ]]; then
        echo "Backup completado: $ARCHIVO_DESTINO"
        exit 0
    else
        echo "Error al crear el respaldo."
        exit 1
    fi
else
    echo "No se encontraron rutas válidas para respaldo."
    exit 1
fi