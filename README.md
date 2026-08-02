Autores:
Miguel Angel Terrones Cajamuni y Williams Mogollon Zapata

# Sistema de Automatización de Respaldos y Monitoreo Web

## Descripción
Este proyecto automatiza la creación de copias de seguridad de directorios críticos en entornos Linux y genera un reporte dinámico en formato HTML accesible a través de un servidor web Nginx. Es una solución modular diseñada para garantizar la disponibilidad de la información, minimizar errores humanos y proveer auditoría en tiempo real.

## Características Principales
* **Menú Interactivo:** Un orquestador principal (`examen_final.sh`) que facilita la administración del sistema mediante una interfaz de consola.
* **Copias de Seguridad Automatizadas:** Empaqueta y comprime directorios clave (como `/etc` y `/var/log`) usando herramientas nativas (`tar` y `gzip`) con marcas de tiempo únicas[cite: 9].
* **Validaciones Robustas:** Verifica la ejecución con privilegios de superusuario (`sudo`), comprueba la existencia física de los directorios antes de respaldarlos y maneja excepciones en caso de fallos de compresión.
* **Generación de Reportes Web:** Procesa la bitácora del sistema mediante utilidades avanzadas (`grep` y `awk`) para actualizar dinámicamente el portal web inyectando código HTML directamente en el servidor.
* **Auditoría Continua:** Registra todos los eventos (éxitos, advertencias y errores críticos) en un archivo centralizado ubicado en `/var/log/backup.log`.

## Requisitos Previos
Para el correcto funcionamiento de este sistema, se requiere:
* Un sistema operativo basado en Linux (Ej: Rocky Linux, CentOS, Ubuntu).
* Privilegios de administrador de sistema (acceso `root` o `sudo`).
* Servidor web **Nginx** instalado y en ejecución.

## Estructura de Archivos
* `examen_final.sh`: Script orquestador principal e interfaz interactiva para el usuario.
* `motor_backup.sh`: Módulo transaccional encargado de validar rutas, crear el directorio contenedor seguro (`/var/backups/sistema/`) y realizar la compresión.
* `reporte_web.sh`: Módulo de análisis que lee los registros y reconstruye la interfaz gráfica web (`index.html`) para Nginx.

## Instalación y Configuración
1. Clona este repositorio en tu servidor Linux:
   ```bash
   git clone <URL_DE_TU_REPOSITORIO>

1. Navega al directorio del proyecto y otorga permisos de ejecución a los scripts:
chmod +x *.sh

2. Verifica que el servicio Nginx esté activo:
sudo systemctl start nginx
sudo systemctl enable nginx

3. Uso del Sistema
Inicia el orquestador principal utilizando privilegios de superusuario:
sudo ./examen_final.sh

4. Opciones del Menú:
- Ejecutar Backup de Directorios Clave: Invoca al motor de respaldo para empaquetar los directorios y registra el resultado de la operación.
- Verificar estado del servidor Nginx: Evalúa de manera silenciosa si el demonio web está operando correctamente y muestra el estado en pantalla.
- Visualizar bitácora local: Imprime las últimas 20 líneas del archivo central de registros de respaldo.
- Generar y actualizar reporte Web HTML: Filtra los registros recientes y regenera el portal de monitoreo alojado en /usr/share/nginx/html/index.html.  
- Salir: Finaliza el bucle interactivo y cierra el sistema.
