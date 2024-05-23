local CONSTANTS = require("./controllers/constant")
local population = require("./controllers/population")

-- Copie un objet et renvoie l'objet copié
-- Source: http://lua-users.org/wiki/CopyTable
local function copier(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[copier(orig_key)] = copier(orig_value)
        end
        setmetatable(copy, copier(getmetatable(orig)))
    else -- number, string, boolean, etc.
        copy = orig
    end
    return copy
end

-- Retourne la position de Mario (x, y)
local function getPositionMario()
    return {
        x = memory.read_s16_le(0x94),
        y = memory.read_s16_le(0x96)
    }
end

-- Retourne la position de la caméra (x, y)
local function getPositionCamera()
    return {
        x = memory.read_s16_le(0x1462),
        y = memory.read_s16_le(0x1464)
    }
end

-- Génère un poids aléatoire (pour les connexions) égal à 1 ou -1
local function genererPoids()
    return (math.random() >= 0.5) and -1 or 1
end

-- Fonction d'activation sigmoïde
local function sigmoid(x)
    local result = x / (1 + math.abs(x))
    return result >= 0.5
end

-- Renvoie le nom du fichier de sauvegarde
local function getNomFichierSauvegarde()
    return string.gsub(CONSTANTS.POPULATION_FILE, "idGen", tostring(CONSTANTS.GLOBALS.generation_number))
end

-- Renvoie l'indice du tableau lesInputs avec les coordonnées x y
local function getIndiceLesInputs(x, y)
    return x + ((y - 1) * CONSTANTS.TILE_COUNT_WIDTH)
end

-- Convertit une position pour obtenir les arguments x et y du tableau lesInputs
local function convertirPositionPourInput(position)
    local mario = getPositionMario()
    mario.x = mario.x - CONSTANTS.VIEW_WIDTH / 2
    mario.y = mario.y - CONSTANTS.VIEW_HEIGHT / 2

    return {
        x = math.floor((position.x - mario.x) / CONSTANTS.TILE_SIZE) + 1,
        y = math.floor((position.y - mario.y) / CONSTANTS.TILE_SIZE) + 1
    }
end

-- Retourne une liste des positions (x, y) des sprites à l'écran (taille max 10)
local function getLesSprites()
    local lesSprites = {}
    local j = 1
    for i = 0, CONSTANTS.MAX_SPRITE_COUNT do
        if memory.readbyte(0x14C8 + i) > 7 then
            lesSprites[j] = {
                x = memory.readbyte(0xE4 + i) + memory.readbyte(0x14E0 + i) * 256,
                y = math.floor(memory.readbyte(0xD8 + i) + memory.readbyte(0x14D4 + i) * 256)
            }
            j = j + 1
        end
    end

    for i = 0, CONSTANTS.MAX_SPRITE_COUNT do
        if memory.readbyte(0x170B + i) ~= 0 then
            lesSprites[j] = {
                x = memory.readbyte(0x171F + i) + memory.readbyte(0x1733 + i) * 256,
                y = math.floor(memory.readbyte(0x1715 + i) + memory.readbyte(0x1729 + i) * 256)
            }
            j = j + 1
        end
    end

    return lesSprites
end

-- Renvoie une table de tiles autour de Mario
local function getLesTiles()
    local lesTiles = {}
    local mario = getPositionMario()
    mario.x = mario.x - CONSTANTS.VIEW_WIDTH / 2
    mario.y = mario.y - CONSTANTS.VIEW_HEIGHT / 2

    for i = 1, CONSTANTS.TILE_COUNT_WIDTH do
        for j = 1, CONSTANTS.TILE_COUNT_HEIGHT do
            local xT = math.ceil((mario.x + ((i - 1) * CONSTANTS.TILE_SIZE)) / CONSTANTS.TILE_SIZE)
            local yT = math.ceil((mario.y + ((j - 1) * CONSTANTS.TILE_SIZE)) / CONSTANTS.TILE_SIZE)
            local indice = getIndiceLesInputs(i, j)

            if xT > 0 and yT > 0 then
                lesTiles[indice] = memory.readbyte(
                    0x1C800 +
                    math.floor(xT / CONSTANTS.TILE_SIZE) * 0x1B0 +
                    yT * CONSTANTS.TILE_SIZE +
                    xT % CONSTANTS.TILE_SIZE
                )
            else
                lesTiles[indice] = 0
            end
        end
    end

    return lesTiles
end



-- Applique les boutons aux joypads de l'émulateur avec un réseau de neurones
local function appliquerLesBoutons(unReseau)
    local lesBoutonsT = {}
    for i = 1, CONSTANTS.OUTPUT_COUNT do
        lesBoutonsT[CONSTANTS.BUTTONS[i].name] = sigmoid(unReseau.lesNeurones[CONSTANTS.INPUT_COUNT + i].valeur)
    end

    if lesBoutonsT["P1 Left"] and lesBoutonsT["P1 Right"] then
        lesBoutonsT["P1 Left"] = false
    end
    joypad.set(lesBoutonsT)
end

-- Permet de mettre le jeu en pause
local function traitementPause()
    local lesBoutons = joypad.get(1)
    lesBoutons["P1 Start"] = not lesBoutons["P1 Start"]
    joypad.set(lesBoutons)
end

-- Gestion de la fin du script
event.onexit(function()
    console.log("Fin du script")
    gui.clearGraphics()
    forms.destroy(form)
end)

-- Active la sauvegarde
local function activerSauvegarde()
    sauvegarderPopulation(laPopulation, false)
end

-- Active le chargement
local function activerChargement()
    local chemin = forms.openfile()
    if chemin ~= "" then
        local laPopulationT = chargerPopulation(chemin)
        if laPopulationT then
            laPopulation = copier(laPopulationT)
            idPopulation = 1
            lancerNiveau()
        end
    end
end

-- Renvoie les inputs, créés en fonction de la position de Mario
local function getLesInputs()
    local lesInputs = {}
    for i = 1, CONSTANTS.TILE_COUNT_WIDTH do
        for j = 1, CONSTANTS.TILE_COUNT_HEIGHT do
            lesInputs[getIndiceLesInputs(i, j)] = 0
        end
    end

    local lesSprites = getLesSprites()
    for _, sprite in ipairs(lesSprites) do
        local input = convertirPositionPourInput(sprite)
        if input.x > 0 and input.x < CONSTANTS.TILE_COUNT_WIDTH + 1 then
            lesInputs[getIndiceLesInputs(input.x, input.y)] = -1
        end
    end

    local lesTiles = getLesTiles()
    for i = 1, CONSTANTS.TILE_COUNT_WIDTH do
        for j = 1, CONSTANTS.TILE_COUNT_HEIGHT do
            local indice = getIndiceLesInputs(i, j)
            if lesTiles[indice] ~= 0 then
                lesInputs[indice] = lesTiles[indice]
            end
        end
    end

    return lesInputs
end



return {
    copier = copier,
    genererPoids = genererPoids,
    sigmoid = sigmoid,
    getNomFichierSauvegarde = getNomFichierSauvegarde,
    getIndiceLesInputs = getIndiceLesInputs,
    getLesInputs = getLesInputs,
    getLesSprites = getLesSprites,
    getLesTiles = getLesTiles,
    getPositionMario = getPositionMario,
    getPositionCamera = getPositionCamera,
    convertirPositionPourInput = convertirPositionPourInput,
    appliquerLesBoutons = appliquerLesBoutons,
    traitementPause = traitementPause,
    activerSauvegarde = activerSauvegarde,
    activerChargement = activerChargement
}
