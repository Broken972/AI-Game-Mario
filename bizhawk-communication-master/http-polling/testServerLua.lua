-- Chemin vers le répertoire où les bibliothèques LuaSocket et dkjson sont placées
package.path = package.path .. ";D:/Documents/IA/AI-Game-Mario/BizHawk/lua/?.lua;D:/Documents/IA/AI-Game-Mario/BizHawk/lua/socket/?.lua"
package.cpath = package.cpath .. ";D:/Documents/IA/AI-Game-Mario/BizHawk/lua/socket/?.dll"

-- Charger les bibliothèques LuaSocket et dkjson
local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")

local url = "http://127.0.0.1:3000/update"
local frameCount = 0

-- Fonction pour envoyer une requête HTTP POST
function send_update(score, status)
    local data = {
        instance_id = os.getenv("INSTANCE_ID") or 1,
        score = score,
        status = status
    }

    -- Convertir la table en JSON
    local json_data = json.encode(data)

    -- Préparer la requête HTTP POST
    local response_body = {}

    local res, code, response_headers = http.request{
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#json_data)
        },
        source = ltn12.source.string(json_data),
        sink = ltn12.sink.table(response_body)
    }

    if code ~= 200 then
        print("Failed to send update: " .. (code or "nil"))
    else
        print("Update sent successfully")
    end
end

-- Boucle principale pour avancer le frame et effectuer des actions périodiquement
while true do
    -- Logique pour obtenir le score et le statut de l'IA
    local score = 100  -- Exemple de score (remplacez par votre logique)
    local status = "running"  -- Exemple de statut (remplacez par votre logique)

    -- Envoyer les données au serveur web toutes les 60 frames (ajustez selon vos besoins)
    if (frameCount % 60 == 0) then
        send_update(score, status)
    end

    emu.frameadvance()  -- Avancer d'un frame dans l'émulateur
    frameCount = frameCount + 1  -- Incrémenter le compteur de frames
end
