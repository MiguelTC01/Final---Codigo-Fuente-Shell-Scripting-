#!/bin/bash
# ==============================================================================
# SCRIPT: motor_backup.sh
# DESCRIPCIÓN: Módulo transaccional de respaldos.
#              Valida la existencia de directorios, empaqueta el contenido con
#              compresión tar/gzip y registra eventos en la bitácora.
# ==============================================================================

# --- CONFIGURACIÓN DE PARÁMETROS Y VARIABLES DE TRABAJO ---
# Si las variables no vienen heredadas desde el script principal, se asignan valores por defecto.
BACKUP_DIR="${BACKUP_DIR:-/var/backups/sistema}"
LOG_FILE="${LOG_FILE:-/var/log/backup.log}"

# Array que define la lista de directorios críticos del sistema que se van a respaldar
DIRECTORIOS_CLAVE=("/etc" "/var/log")

# Genera una estampa de tiempo única con formato YYYYMMDD_HHMMSS (Ej: 20260728_190742)
FECHA=$(date +"%Y%m%d_%H%M%S")

# Construye el nombre absoluto del archivo de salida comprimido .tar.gz
ARCHIVO_DESTINO="${BACKUP_DIR}/backup_infra_${FECHA}.tar.gz"


# --- CREACIÓN Y VERIFICACIÓN DEL DIRECTORIO DESTINO ---
# Verifica mediante '! -d' si el directorio de destino NO existe físicamente
if [[ ! -d "$BACKUP_DIR" ]]; then
    # Crea el directorio y sus carpetas padres si fuera necesario (-p)
    mkdir -p "$BACKUP_DIR"
    
    # Asigna permisos octales 700 (Lectura, escritura y ejecución EXCLUSIVA para el propietario root)
    chmod 700 "$BACKUP_DIR"
    
    # Redirige (append '>>') el registro de auditoría a la bitácora del sistema
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [INFO] Directorio de backup creado exitosamente." >> "$LOG_FILE"
fi


# --- VALIDACIÓN DE EXISTENCIA DE CARPETAS A RESPALDAR ---
# Array dinámico acumulador para almacenar solo aquellas rutas cuya existencia sea verificada
RUTAS_VALIDAS=()

# Bucle 'for' que recorre cada elemento del array DIRECTORIOS_CLAVE
for dir in "${DIRECTORIOS_CLAVE[@]}"; do
    # Evalúa si la carpeta existe físicamente en el sistema de archivos
    if [[ -d "$dir" ]]; then
        # Concatena la ruta validada al final del array RUTAS_VALIDAS
        RUTAS_VALIDAS+=("$dir")
    else
        # Si un directorio configurado no existe, lo registra como advertencia en el log
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [ADVERTENCIA] El directorio $dir no existe. Omitiendo..." >> "$LOG_FILE"
    fi
done


# --- PROCESO DE EMPAQUETADO Y COMPRESIÓN ---
# Evaluamos mediante '${#array[@]}' que el número de rutas válidas encontradas sea mayor a cero (-gt 0)
if [[ ${#RUTAS_VALIDAS[@]} -gt 0 ]]; then
    # Ejecuta el empaquetado:
    # -c : Crea un nuevo archivo de archivo.
    # -z : Comprime el archivo usando el algoritmo gzip.
    # -f : Especifica el nombre del archivo de salida.
    # 2>/dev/null : Redirige y descarta advertencias menores del sistema (archivos abiertos/modificados durante la lectura)
    tar -czf "$ARCHIVO_DESTINO" "${RUTAS_VALIDAS[@]}" 2>/dev/null
    STATUS=$?  # Captura de forma inmediata el código de retorno devuelto por el comando tar

    # En la herramienta 'tar':
    # Código 0 = Operación exitosa sin inconvenientes.
    # Código 1 = Archivos modificados mientras se leían (aceptable para backups en caliente).
    if [[ $STATUS -eq 0 || $STATUS -eq 1 ]]; then
        # Extrae el tamaño formateado (human-readable) del archivo generado usando 'du' y aislando el valor con 'cut'
        TAMANO=$(du -sh "$ARCHIVO_DESTINO" | cut -f1)

        # Registra la confirmación de respaldo exitoso en el archivo de log central
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [ÉXITO] Backup $ARCHIVO_DESTINO creado. Tamaño: $TAMANO" >> "$LOG_FILE"
        exit 0  # Finalización exitosa del script
    else
        # Registra fallo crítico en caso de error grave durante la compresión
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] Fallo crítico al empaquetar archivos con tar." >> "$LOG_FILE"
        exit 1  # Finalización con código de error
    fi
else
    # Error registrado en caso de que ninguna carpeta de la lista exista en el sistema
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [ERROR] Ninguna ruta origen fue válida para el respaldo." >> "$LOG_FILE"
    exit 1
fi