#!/bin/bash

# Función para instalar Java
function install_java {
    # Solicita la versión de Java a instalar
    read -p "Ingresa la versión de Java que deseas instalar (por ejemplo, 8, 11, 16, 17 o 18): " version

    # Instala Java utilizando el sistema de paquetes de apt
    apt-get update
    apt-get install -y openjdk-${version}-jdk

    # Establece las variables de entorno necesarias
    echo "export JAVA_HOME=/usr/lib/jvm/java-${version}-openjdk-amd64" >> /etc/profile
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
    source /etc/profile
}


# Función para instalar PaperMC
function install_paper {
    # Solicita la versión de PaperMC a instalar
    read -p "Ingresa la versión de PaperMC que deseas instalar (por ejemplo, 1.16.5): " software_version

    # Descarga la última build de la versión de PaperMC especificada
    cd /opt/papermc
    mkdir -p "${software_version}"
    cd "${software_version}"
    build_number=$(curl -s "https://papermc.io/api/v2/projects/paper/versions/${software_version}/" | jq '.builds[-1]' | jq '.build' | tr -d '\n')
    curl -o "paper-${software_version}-${build_number}.jar" "https://papermc.io/api/v2/projects/paper/versions/${software_version}/builds/${build_number}/downloads/paper-${software_version}-${build_number}.jar"

    # Crea el script de inicio de PaperMC
    echo "#!/bin/sh" > start.sh
    echo "java -Xms${memory} -Xmx${memory} -jar paper-${software_version}-${build_number}.jar" >> start.sh
    chmod +x start.sh
}


# Función para instalar MariaDB
function install_mariadb {
    # Instala MariaDB
    apt-get update
    apt-get install -y mariadb-server
}

# Función para instalar phpMyAdmin
function install_phpmyadmin {
    # Instala phpMyAdmin
    apt-get update
    apt-get install -y phpmyadmin php-mbstring php-zip php-gd php-json php-curl
    echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
    systemctl restart apache2
}

# Función para subir un archivo de log a https://pteropaste.com/
function upload_log {
    # Busca las carpetas en la ruta /home y las muestra al usuario
    echo "Carpetas disponibles en /home:"
    find /home -maxdepth 1 -type d -printf '%f\n'

    # Solicita el nombre de la carpeta que contiene el archivo de log
    read -p "Ingresa el nombre de la carpeta que contiene el archivo de log: " folder_name

    # Verifica que la carpeta exista
    if [ ! -d "/home/$folder_name" ]; then
        echo "La carpeta no existe."
        return
    fi

    # Busca el archivo de log más reciente en la carpeta especificada
    log_file=$(find "/home/$folder_name/logs" -maxdepth 1 -name "latest.log" -o -name "lasted.log" -type f | sort -r | head -n1)

    # Verifica que se haya encontrado un archivo de log
    if [ -z "$log_file" ]; then
        echo "No se encontró un archivo de log en la carpeta especificada."
        return
    fi

        # Utiliza la herramienta tail para extraer las últimas 100 líneas del archivo de log y las envía a https://pteropaste.com/ utilizando netcat
    url=$(tail -n 100 "$log_file" | nc -w 10 pteropaste.com 99 | grep -o 'https://pteropaste.com/[0-9a-zA-Z]*')

    # Muestra el URL de respuesta en la consola
    echo "El archivo de log se ha subido correctamente a: $url"
}

# Función para cerrar un puerto con UFW
function close_port {
    # Verifica si UFW está activo
    if ! systemctl is-active --quiet ufw; then
        # Si UFW no está activo, pregunta si desea activarlo
        read -p "UFW no está activo. ¿Deseas activarlo? [S/n]: " activate
        case $activate in
            [nN]* ) return ;;
            * )
                # Activa UFW
                systemctl start ufw
                systemctl enable ufw
        esac
    fi

    # Solicita el número de puerto a cerrar
    read -p "Ingresa el número de puerto que deseas cerrar: " port

    # Cierra el puerto con UFW
    ufw deny "$port"
    echo "El puerto $port ha sido cerrado correctamente."
}

# Función para mostrar información del sistema
function show_system_info {
    # Obtiene el modelo de la CPU
    cpu_model=$(cat /proc/cpuinfo | grep "model name" | head -n 1 | cut -d ":" -f 2 | sed 's/^ *//g')

    # Obtiene la cantidad de memoria RAM total, usada y libre
    mem_total=$(free -h | grep "Mem" | awk '{print $2}')
    mem_used=$(free -h | grep "Mem" | awk '{print $3}')
    mem_free=$(free -h | grep "Mem" | awk '{print $4}')

    # Obtiene el espacio en disco disponible
    disk_space=$(df -h / | grep -v Filesystem | awk '{print $4}')

    # Obtiene la cantidad de núcleos y hilos
    cpu_cores=$(grep -c '^processor' /proc/cpuinfo)
    cpu_threads=$(grep -c '^thread' /proc/cpuinfo)

    # Muestra la información en la consola
    echo "Información del sistema:"
    echo "Modelo de CPU: $cpu_model"
    echo "Memoria RAM total: $mem_total"
    echo "Memoria RAM usada: $mem_used"
    echo "Memoria RAM libre: $mem_free"
    echo "Espacio en disco: $disk_space"
    echo "Núcleos: $cpu_cores"
    echo "Hilos: $cpu_threads"
}

# Función para mostrar el menú de opciones
function show_menu {
    echo "Seleccione una opción:"
    echo "1. Instalar Java"
    echo "2. Instalar Software"
    echo "3. Instalar MariaDB"
    echo "4. Instalar phpMyAdmin"
    echo "5. Subir archivo de log a Hastebin"
    echo "6. Cerrar un puerto con UFW"
    echo "7. Ver información del sistema"
    echo "8. Salir"

    read -p "Ingresa el número de la opción deseada: " choice
    case $choice in
        1) install_java ;;
        2) install_paper ;;
        3) install_mariadb ;;
        4) install_phpmyadmin ;;
        5) upload_log ;;
        6) close_port ;;
        7) show_system_info ;;
        8) exit ;;
        *) echo "Opción inválida"; show_menu ;;
    esac
}

# Muestra el menú de opciones
while true; do
    show_menu
done
