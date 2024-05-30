import subprocess
import time
import os

def log(message):
    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {message}")

def check_file_exists(file_path, description):
    if not os.path.isfile(file_path):
        raise FileNotFoundError(f"{description} introuvable : {file_path}")
    log(f"{description} trouvé : {file_path}")

def make_absolute_path(path):
    return os.path.abspath(path)

def launch_emuhawk_with_rom_and_script(emuhawk_path, rom_path, script_path):
    emuhawk_path = make_absolute_path(emuhawk_path)
    rom_path = make_absolute_path(rom_path)
    script_path = make_absolute_path(script_path)

    try:
        check_file_exists(emuhawk_path, "EmuHawk.exe")
        check_file_exists(rom_path, "ROM")
        check_file_exists(script_path, "Script Lua")

        log("Lancement de l'émulateur EmuHawk avec la ROM et le script Lua...")
        command = [
            emuhawk_path,
            "--fullscreen",
            "--rom", rom_path,
            "--luaconsole",
            f"--lua={script_path}"
        ]
        process = subprocess.Popen(command)
        time.sleep(5)  # Attendre que l'émulateur se lance
        return process

    except FileNotFoundError as e:
        log(f"Erreur : {e}")
    except Exception as e:
        log(f"Erreur inattendue : {e}")
    return None

def main():
    emuhawk_path = r'D:/Documents/IA/AI-Game-Mario/emu/EmuHawk.exe'
    rom_path = r'D:/Documents/IA/AI-Game-Mario/emu/Super Mario World (USA).sfc'
    script_path = r'D:/Documents/IA/AI-Game-Mario/code/main.lua'
    num_instances = int(input("Combien d'instances voulez-vous lancer? "))
    instances = []

    try:
        for i in range(num_instances):
            log(f"Lancement de l'instance {i+1}...")
            process = launch_emuhawk_with_rom_and_script(emuhawk_path, rom_path, script_path)
            if process:
                instances.append(process)
        log(f"{num_instances} instances lancées.")
    except Exception as e:
        log(f"Erreur : {e}")

    # Attendre que les instances soient fermées par l'utilisateur
    try:
        for instance in instances:
            instance.wait()
    except NameError:
        pass

if __name__ == "__main__":
    main()
