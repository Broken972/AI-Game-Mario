import subprocess
import time
import os
import pygetwindow as gw

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

def organize_windows(num_instances):
    windows = [win for win in gw.getWindowsWithTitle('EmuHawk') if win.isVisible()]
    screen_width = gw.getWindowsWithTitle('')[0].width
    screen_height = gw.getWindowsWithTitle('')[0].height
    
    # Margin between windows
    margin = 10
    
    rows = cols = int(num_instances ** 0.5)
    if rows * cols < num_instances:
        cols += 1
    if rows * cols < num_instances:
        rows += 1
    
    window_width = (screen_width - (cols + 1) * margin) // cols
    window_height = (screen_height - (rows + 1) * margin) // rows

    for i, win in enumerate(windows[:num_instances]):
        row = i // cols
        col = i % cols
        x = col * (window_width + margin) + margin
        y = row * (window_height + margin) + margin
        win.moveTo(x, y)
        win.resizeTo(window_width, window_height)

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
        
        # Organize windows after launching all instances
        time.sleep(10)  # Wait for all instances to be fully launched
        organize_windows(num_instances)
        
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
