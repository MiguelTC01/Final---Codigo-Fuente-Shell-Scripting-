#!/bin/bash
# ==============================================================================
# Script: motor_backup.sh (v0.2)
# Descripción: Motor de respaldo con auditoría y logs detallados.
# ==============================================================================

BACKUP_DIR="/var/backups/sistema"
LOG_FILE="/var/log/backup.log"
DIRECTORIOS_CLAVE=("/etc" "/var/log")
FECHA=$(date +"%Y%m%d_%H%M%S")
ARCHIVO_DESTINO="${BACKUP_DIR}/backup_infra_${FECHA}.tar.gz"

if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir -p "$BACKUP_DIR"
    chmod 700 "$BACKUP_DIR"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] Directorio de backup creado exitosamente." >> "$LOG_FILE"
fi

RUTAS_VALIDAS=()
for dir in "${DIRECTORIOS_CLAVE[@]}"; do
    if [[ -d "$dir" ]]; then
        RUTAS_VALIDAS+=("$dir")
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [ADVERTENCIA] El directorio $dir no existe. Omitiendo..." >> "$LOG_FILE"
    fi
done

if [[ ${#RUTAS_VALIDAS[@]} -gt 0 ]]; then
    tar -czf "$ARCHIVO_DESTINO" "${RUTAS_VALIDAS[@]}" 2>/dev/null
    STATUS=$?

    if [[ $STATUS -eq 0 || $STATUS -eq 1 ]]; then
        TAMANO=$(du -sh "$ARCHIVO_DESTINO" | cut -f1)
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [ÉXITO] Backup $ARCHIVO_DESTINO creado. Tamaño: $TAMANO" >> "$LOG_FILE"
        exit 0
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] Fallo crítico al empaquetar archivos con tar." >> "$LOG_FILE"
        exit 1
    fi
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] Ninguna ruta origen fue válida para el respaldo." >> "$LOG_FILE"
    exit 1
fi