#!/bin/bash
# ==============================================================================
# SCRIPT: reporte_web.sh
# DESCRIPCIÓN: Módulo de procesamiento de registros e interfaz.
#              Analiza la bitácora con comandos de filtro y texto (grep/awk)
#              y genera dinámicamente la página web index.html para Nginx.
# ==============================================================================

# --- DECLARACIÓN DE RUTAS ---
WEB_DIR="${WEB_DIR:-/usr/share/nginx/html}"
LOG_FILE="${LOG_FILE:-/var/log/backup.log}"

# --- VALIDACIÓN DE EXISTENCIA DE LA BITÁCORA ---
# Verifica si la bitácora no existe antes de intentar procesarla (-f)
if [[ ! -f "$LOG_FILE" ]]; then
    echo "[ERROR] No se encontró el archivo de log para generar el reporte."
    exit 1
fi

# Crea el directorio web si aún no estuviera presente
mkdir -p "$WEB_DIR"

# --- PROCESAMIENTO AVANZADO DE TEXTO CON PIPELINES ---

# EXPLICACIÓN DEL PIPELINE PARA RESPALDOS EXITOSOS:
# 1. grep "\[ÉXITO\]": Filtra únicamente las líneas que contengan la etiqueta de éxito.
# 2. tail -n 15: Selecciona las últimas 15 entradas del historial para no saturar la vista.
# 3. awk -F" - " '{...}': Utiliza el separador ' - ' para dividir la línea en $1 (Fecha) y $2 (Mensaje),
#    formateándolos directamente dentro de etiquetas HTML <li>.
EXITOS_HTML=$(grep "\[ÉXITO\]" "$LOG_FILE" | tail -n 15 | awk -F" - " '{print "<li><b>Fecha:</b> "$1" | <b>Detalle:</b> "$2"</li>"}')

# EXPLICACIÓN DEL PIPELINE PARA ERRORES Y ADVERTENCIAS:
# 1. grep -E: Habilita expresiones regulares extendidas para buscar múltiples patrones ("\[ADVERTENCIA\]|\[ERROR\]").
# 2. tail -n 5: Captura las últimas 5 incidencias registradas.
# 3. awk: Formatea la línea e inyecta estilo CSS en línea (color rojo #c0392b) para resaltar alertas.
ERRORES_HTML=$(grep -E "\[ADVERTENCIA\]|\[ERROR\]" "$LOG_FILE" | tail -n 5 | awk -F" - " '{print "<li style=\"color:#c0392b;\"><b>Fecha:</b> "$1" | <b>Detalle:</b> "$2"</li>"}')

# --- GENERACIÓN DINÁMICA DEL ARCHIVO HTML ---
# Se utiliza la sintaxis 'cat << EOF > ruta' (Here-Document) para escribir
# un bloque masivo de código HTML y CSS procesado dinámicamente hacia index.html.
cat << EOF > "$WEB_DIR/index.html"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Copias de Seguridad</title>
    <style>
        /* Estilos CSS embebidos para diseño responsivo y limpio */
        body { font-family: Arial, sans-serif; margin: 30px; background-color: #f4f6f9; color: #333; }
        h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; }
        ul { line-height: 1.8; list-style-type: square; }
    </style>
</head>
<body>
    <h1>Servidor de Monitoreo de Backups</h1>
    <!-- Inyección dinámica de la fecha y hora de la última actualización del reporte -->
    <p><b>Última actualización:</b> $(date '+%Y-%m-%d %H:%M:%S')</p>

    <div class="card">
        <h2 style="color: #27ae60;">Historial de Respaldos Exitosos</h2>
        <ul>
            <!-- Uso de la expansión de variables por defecto (${VAR:-default}): 
                 Si EXITOS_HTML está vacía, imprime el mensaje alternativo dentro del <li> -->
            ${EXITOS_HTML:-<li>No hay registros de éxito recientes.</li>}
        </ul>
    </div>

    <div class="card">
        <h2 style="color: #c0392b;">Alertas e Incidentes Detectados</h2>
        <ul>
            ${ERRORES_HTML:-<li>Sin alertas de error registradas. Sistema estable.</li>}
        </ul>
    </div>
</body>
</html>
EOF

# --- NOTIFICACIÓN DE SALIDA EN CONSOLA ---
# Confirma en la terminal que el archivo fue generado correctamente
echo "[ÉXITO] Reporte publicado en la web. Abra 192.168.248.130 en su navegador."