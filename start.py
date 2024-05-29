import subprocess
import time
import pyautogui
import os

def launch_emuhawk(emuhawk_path, rom_path, save_state_path, script_path, num_instances):
    instances = []
    for i in range(num_instances):
        # Vérifiez si le fichier EmuHawk.exe existe
        if not os.path.isfile(emuhawk_path):
            raise FileNotFoundError(f"EmuHawk.exe introuvable : {emuhawk_path}")
        
        # Vérifiez si le fichier de ROM existe
        if not os.path.isfile(rom_path):
            raise FileNotFoundError(f"ROM introuvable : {rom_path}")

        # Lancer l'émulateur EmuHawk avec le chemin de la ROM
        process = subprocess.Popen([emuhawk_path, rom_path])
        instances.append(process)
        time.sleep(5)  # Attendre que l'émulateur se lance

        # Charger la sauvegarde
        pyautogui.hotkey('ctrl', 'l')  # Assurez-vous que le raccourci est correct
        time.sleep(1)
        pyautogui.typewrite(save_state_path)
        pyautogui.press('enter')
        time.sleep(1)

        # Injecter le script AI
        pyautogui.hotkey('alt', 'f')
        time.sleep(1)
        pyautogui.typewrite('Script Console')
        pyautogui.press('enter')
        time.sleep(1)
        pyautogui.typewrite(f'dofile("{script_path}")')  # Assurez-vous que le chemin est correct
        pyautogui.press('enter')
        time.sleep(1)

    return instances

def main():
    emuhawk_path = r'D:/Documents/IA/AI-Game-Mario/emu/EmuHawk.exe'
    rom_path = r'D:/Documents/IA/AI-Game-Mario/emu/Super Mario World (USA).sfc'
    save_state_path = r'D:/Documents/IA/AI-Game-Mario/codeIA/best_run_20240524222530.state'
    script_path = r'D:/Documents/IA/AI-Game-Mario/codeIA/main.lua'
    num_instances = int(input("Combien d'instances voulez-vous lancer? "))

    try:
        instances = launch_emuhawk(emuhawk_path, rom_path, save_state_path, script_path, num_instances)
        print(f"{num_instances} instances lancées.")
    except FileNotFoundError as e:
        print(e)
        return

    # Attendre que les instances soient fermées par l'utilisateur
    for instance in instances:
        instance.wait()

if __name__ == "__main__":
    main()
