#!/bin/bash
# ==============================================================================
# SCRIPT: examen_final.sh
# DESCRIPCIÓN: Script orquestador principal del sistema de automatización.
#              Proporciona un menú interactivo en consola para administrar
#              respaldos del sistema, verificar servicios y generar reportes.
# ==============================================================================

# --- DECLARACIÓN Y EXPORTACIÓN DE VARIABLES DE ENTORNO ---
# Se utiliza 'export' para que las variables globales queden disponibles 
# en los procesos secundarios (subshells) que invocan a otros scripts.
export BACKUP_DIR="/var/backups/sistema"      # Ruta donde se almacenarán los archivos comprimidos
export LOG_FILE="/var/log/backup.log"          # Ruta del archivo central de bitácora y auditoría
export SCRIPT_DIR=$(pwd)                       # Almacena el directorio de trabajo actual dinámicamente
export WEB_DIR="/usr/share/nginx/html"         # Directorio raíz por defecto del servidor web Nginx

# --- VALIDACIÓN DE PRIVILEGIOS DE SUPERUSUARIO (ROOT) ---
# $EUID (Effective User ID) almacena el ID del usuario actual.
# El usuario 'root' siempre tiene el ID 0. Si no se ejecuta con sudo, se aborta la ejecución.
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script requiere privilegios administrativos. Ejecute con sudo." >&2
    exit 1  # Retorna código de salida 1 (error general)
fi

# --- BUCLE INTERACTIVO PRINCIPAL ---
# Bucle infinito 'while true' que redibuja el menú tras cada acción hasta seleccionar la opción de salir.
while true; do
    clear  # Limpia la pantalla de la terminal para mantener una interfaz limpia

    # Encabezado visual formateado
    echo "=================================================="
    echo "  EVALUACIÓN FINAL: SISTEMA DE RESPALDO Y NGINX   "
    echo "=================================================="
    echo " 1. Ejecutar Backup de Directorios Clave"
    echo " 2. Verificar estado del servidor Nginx"
    echo " 3. Visualizar bitácora local (backup.log)"
    echo " 4. Generar y actualizar reporte Web HTML"
    echo " 5. Salir"
    echo "=================================================="

    # Captura la opción seleccionada por el usuario en la variable OPCION
    read -p "Seleccione una opción [1-5]: " OPCION

    # Evaluación de la opción ingresada mediante una estructura condicional 'case'
    case $OPCION in
        1)
            echo -e "\nIniciando proceso de respaldo..."
            # Invoca al motor de respaldo 'motor_backup.sh' en una subshell Bash.
            # Verifica si el comando finalizó con un código de retorno exitoso ($? = 0).
            if bash "$SCRIPT_DIR/motor_backup.sh"; then
                echo -e "\n[ÉXITO] Proceso de respaldo finalizado correctamente."
                echo "Utilice la Opción 4 para actualizar la interfaz web de monitoreo."
            else
                echo -e "\n[ERROR] El proceso de respaldo falló. Revise la bitácora local (Opción 3)."
            fi

            # Pausa la ejecución hasta que el usuario presione una tecla
            read -p "Presione [Enter] para continuar..."
            ;;

        2)
            echo -e "\nVerificando servicio Nginx..."
            # 'systemctl is-active --quiet' evalúa si el demonio Nginx está activo.
            # La bandera '--quiet' reprime la salida en pantalla para usar solo el código de retorno ($?).
            if systemctl is-active --quiet nginx; then
                echo "Estado: Nginx está EJECUTÁNDOSE correctamente."
            else
                echo "Estado: Nginx está DETENIDO o no instalado."
            fi

            read -p "Presione [Enter] para continuar..."
            ;;

        3)
            echo -e "\n--- ÚLTIMOS REGISTROS EN BITÁCORA ($LOG_FILE) ---"
            # Evalúa si el archivo de log existe en el sistema antes de intentar leerlo (-f)
            if [[ -f "$LOG_FILE" ]]; then
                # Muestra únicamente las últimas 20 entradas utilizando el comando 'tail'
                tail -n 20 "$LOG_FILE"
            else
                echo "[ERROR] El archivo de registro $LOG_FILE no existe aún."
            fi
            echo "--------------------------------------------------------"

            read -p "Presione [Enter] para continuar..."
            ;;

        4)
            echo -e "\nGenerando reporte web..."
            # Comprobación de seguridad previa para verificar la disponibilidad de Nginx
            if ! systemctl is-active --quiet nginx; then
                echo -e "\n[ADVERTENCIA] El servicio Nginx no está activo."
                echo "El archivo HTML se actualizará en disco, pero no se podrá visualizar en el navegador hasta iniciar Nginx."
            fi

            # Invoca el script generador de la interfaz web
            bash "$SCRIPT_DIR/reporte_web.sh"

            read -p "Presione [Enter] para continuar..."
            ;;

        5)
            # Salida limpia del programa
            echo "Saliendo del sistema..."
            exit 0  # Retorna código 0 indicando terminación exitosa sin errores
            ;;

        *)
            # Manejo de entradas no contempladas en las opciones válidas
            echo "Opción no válida. Intente de nuevo."
            sleep 1.5  # Pausa de 1.5 segundos antes de volver a dibujar el menú
            ;;
    esac
done