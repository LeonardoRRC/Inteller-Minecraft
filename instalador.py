import requests
import platform
import psutil
from print_color import print

def get_system_info():
    ram = psutil.virtual_memory()
    total_ram = ram.total / (1024 ** 3)
    available_ram = ram.available / (1024 ** 3)
    cores = psutil.cpu_count(logical=False)
    threads = psutil.cpu_count(logical=True)
    disk_usage = psutil.disk_usage("/")
    total_disk_space = disk_usage.total / (1024 ** 3)
    used_disk_space = disk_usage.used / (1024 ** 3)
    free_disk_space = disk_usage.free / (1024 ** 3)
    swap = psutil.swap_memory()
    total_swap = swap.total / (1024 ** 3)
    used_swap = swap.used / (1024 ** 3)
    free_swap = swap.free / (1024 ** 3)

    print(f"RAM total: {total_ram:.2f} GB", color='cyan')
    print(f"RAM disponible: {available_ram:.2f} GB", color='cyan')
    print(f"Número de núcleos: {cores}", color='cyan')
    print(f"Número de hilos: {threads}", color='cyan')
    print(f"Espacio total en disco: {total_disk_space:.2f} GB", color='cyan')
    print(f"Espacio usado en disco: {used_disk_space:.2f} GB", color='cyan')
    print(f"Espacio libre en disco: {free_disk_space:.2f} GB", color='cyan')
    print(f"Swap total: {total_swap:.2f} GB", color='cyan')
    print(f"Swap usado: {used_swap:.2f} GB", color='cyan')
    print(f"Swap libre: {free_swap:.2f} GB", color='cyan')

def download_paper():
    url = "https://api.papermc.io/v2/projects/paper"

    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        versions = data["versions"]
        print("Versiones disponibles:", color='blue', background='grey')
        for version in versions:
            print(version, color='blue')
        selected_version = input("Ingrese la versión que desea descargar: ")
        if selected_version in versions:
            builds_url = f"https://api.papermc.io/v2/projects/paper/versions/{selected_version}/builds"
            builds_response = requests.get(builds_url)
            if builds_response.status_code == 200:
                builds_data = builds_response.json()
                latest_build = builds_data["builds"][-1]["build"]
                download_url = f"https://api.papermc.io/v2/projects/paper/versions/{selected_version}/builds/{latest_build}/downloads/paper-{selected_version}-{latest_build}.jar"
                download_response = requests.get(download_url)
                if download_response.status_code == 200:
                    with open(f"paper-{selected_version}-{latest_build}.jar", "wb") as f:
                        f.write(download_response.content)
                    print(f"Jar descargado para la versión {selected_version} y build {latest_build}", tag='Exitoso', tag_color='green', color='white')
                else:
                    print("Error al descargar el jar", tag='Error', tag_color='red', color='white')
            else:
                print("Error al obtener las builds disponibles", tag='Error', tag_color='red', color='white')
        else:
            print("La versión ingresada no es válida", tag='Error', tag_color='red', color='white')
    else:
        print("Error al obtener las versiones disponibles", tag='Error', tag_color='red', color='white')

def main():
    while True:
        print("Menú:", color='yellow')
        print("1. Descargar Paper", color='yellow')
        print("2. Ver información del sistema", color='yellow')
        print("3. Salir", color='yellow')
        option = input("Ingrese una opción: ")
        if option == "1":
            download_paper()
        elif option == "2":
            get_system_info()
        elif option == "3":
            break
        else:
            print("Opción no válida", tag='Error', tag_color='red', color='white')

if __name__ == "__main__":
    main()
