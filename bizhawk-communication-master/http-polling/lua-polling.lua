-- Définir l'URL de base pour les requêtes HTTP
local url = "http://127.0.0.1:8080"
local getUrl = url .. "/get"
local postUrl = url .. "/post"
local frameCount = 0

-- Fonction pour effectuer la requête HTTP GET
function request() 
    local res = comm.httpGet(getUrl) 
    if (res ~= '') then  -- Si la réponse n'est pas vide
        print("Action: " .. res)  
        if (res == 'MUTE') then  
            client.SetSoundOn(false) 
            comm.httpPost(postUrl, "")  
        elseif (res == 'UNMUTE') then  
            client.SetSoundOn(true)  
            comm.httpPost(postUrl, "")  -
        end
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
