-- Définir l'URL de base pour les requêtes HTTP
local url = "http://127.0.0.1:8080"
local getUrl = url .. "/get"
local postUrl = url .. "/post"
local screenshotUrl = url .. "/screenshot"
local frameCount = 0

-- Fonction pour effectuer la requête HTTP GET
function request() 
    local res = comm.httpGet(getUrl) 
    if (res ~= '') then  -- Si la réponse n'est pas vide
        print("Action: " .. res)  
        saveScreenshot()
    end
end

-- Fonction pour capturer une capture d'écran et l'envoyer à une URL
function saveScreenshot()
    local screenshotPath = "screenshot.png"
    client.screenshot(screenshotPath)  -- Capturer la capture d'écran et la sauvegarder localement
    local screenshotData = io.open(screenshotPath, "rb"):read("*all")  -- Lire le fichier image

    if screenshotData then  -- Vérifier si les données de la capture d'écran sont disponibles
        local response = comm.httpPost(screenshotUrl, screenshotData)  -- Envoyer les données de l'image au serveur
        if response then
            print("Screenshot sent, response: " .. response)
        else
            print("Screenshot sent, no response from server.")
        end
    else
        print("Failed to read screenshot data.")
    end
end

-- Boucle principale pour avancer le frame et effectuer des actions périodiquement
while true do
    -- Effectuer une requête toutes les 6 frames (soit environ toutes les 0,1 secondes)
    if (math.fmod(frameCount, 6) == 0) then 
        request()
    end

    emu.frameadvance()  -- Avancer d'un frame dans l'émulateur
    frameCount = frameCount + 1  -- Incrémenter le compteur de frames
end
