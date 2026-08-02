#!/bin/bash
# ==============================================================================
# Script: reporte_txt.sh (v0.2)
# Descripción: Genera resumen de logs en consola / texto plano.
# ==============================================================================

LOG_FILE="/var/log/backup.log"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "[ERROR] No existe el archivo de log $LOG_FILE"
    exit 1
fi

echo "======================================"
echo "      REPORTE DE ESTADO (TEXTO)       "
echo "======================================"
echo "--- Últimos Respaldos Exitosos ---"
grep "\[ÉXITO\]" "$LOG_FILE" | tail -n 5

echo -e "\n--- Últimas Alertas / Errores ---"
grep -E "\[ADVERTENCIA\]|\[ERROR\]" "$LOG_FILE" | tail -n 5
echo "======================================"