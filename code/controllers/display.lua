local CONSTANTS = require("./controllers/constant")
local utils = require("./controllers/utils")

local function dessinerLesInfos(laPopulation, lesEspeces, nbGeneration)
    gui.drawBox(0, 0, 256, 60, "black", "white")
    
    -- Informations générales
    gui.drawText(10, 4, "Generation: " .. nbGeneration, "black")
    gui.drawText(10, 20, "Individu: " .. CONSTANTS.GLOBALS.population_id, "black")
    gui.drawText(10, 36, "Especes: " .. #lesEspeces, "black")
    
    -- Fitness
    local fitness = laPopulation[CONSTANTS.GLOBALS.population_id].fitness
    local max_fitness = CONSTANTS.GLOBALS.max_fitness
    -- gui.drawText(150, 4, "Fitness: " .. fitness, "black")
    gui.drawText(150, 20, "Max Fit: " .. max_fitness, "black")
    
    -- Barres de progression
    local fitness_ratio = fitness / max_fitness
    gui.drawBox(150, 36, 150 + 100 * fitness_ratio, 46, "green", "green")
    gui.drawBox(150 + 100 * fitness_ratio, 36, 250, 46, "red", "red")
end

local function dessinerUnReseau(unReseau)
    local lesInputs = utils.getLesInputs()
    local camera = utils.getPositionCamera()
    local lesPositions = {}

    for i = 1, CONSTANTS.TILE_COUNT_WIDTH do
        for j = 1, CONSTANTS.TILE_COUNT_HEIGHT do
            local indice = utils.getIndiceLesInputs(i, j)
            local xT = CONSTANTS.DISPLAY.ANCHOR_X_INPUT + (i - 1) * CONSTANTS.DISPLAY.INPUT_SIZE
            local yT = CONSTANTS.DISPLAY.ANCHOR_Y_INPUT + (j - 1) * CONSTANTS.DISPLAY.INPUT_SIZE

            local couleurFond = "gray"
            if unReseau.lesNeurones[indice].valeur < 0 then
                couleurFond = "black"
            elseif unReseau.lesNeurones[indice].valeur > 0 then
                couleurFond = "white"
            end

            gui.drawRectangle(xT, yT, CONSTANTS.DISPLAY.INPUT_SIZE, CONSTANTS.DISPLAY.INPUT_SIZE, "black", couleurFond)
            lesPositions[indice] = {x = xT + CONSTANTS.DISPLAY.INPUT_SIZE / 2, y = yT + CONSTANTS.DISPLAY.INPUT_SIZE / 2}
        end
    end

    local mario = utils.convertirPositionPourInput(utils.getPositionMario())
    mario.x = (mario.x - 1) * CONSTANTS.DISPLAY.INPUT_SIZE + CONSTANTS.DISPLAY.ANCHOR_X_INPUT
    mario.y = (mario.y - 1) * CONSTANTS.DISPLAY.INPUT_SIZE + CONSTANTS.DISPLAY.ANCHOR_Y_INPUT
    gui.drawRectangle(mario.x, mario.y, CONSTANTS.DISPLAY.INPUT_SIZE, CONSTANTS.DISPLAY.INPUT_SIZE * 2, "black", "blue")

    for i = 1, CONSTANTS.OUTPUT_COUNT do
        local xT = CONSTANTS.DISPLAY.ANCHOR_X_OUTPUT
        local yT = CONSTANTS.DISPLAY.ANCHOR_Y_OUTPUT + CONSTANTS.DISPLAY.OUTPUT_SPACING_Y * (i - 1)
        local nomT = string.sub(CONSTANTS.BUTTONS[i].name, 4)
        local indice = i + CONSTANTS.INPUT_COUNT

        local couleurFond = utils.sigmoid(unReseau.lesNeurones[indice].valeur) and "white" or "black"
        gui.drawRectangle(xT, yT, CONSTANTS.DISPLAY.OUTPUT_WIDTH, CONSTANTS.DISPLAY.OUTPUT_HEIGHT, "white", couleurFond)

        local strValeur = string.format("%.2f", unReseau.lesNeurones[indice].valeur)
        gui.drawText(xT + CONSTANTS.DISPLAY.OUTPUT_WIDTH, yT - 1, nomT, "white", "black", 10)
        lesPositions[indice] = {x = xT + CONSTANTS.DISPLAY.OUTPUT_WIDTH / 2, y = yT + CONSTANTS.DISPLAY.OUTPUT_HEIGHT / 2}
    end

    for i = 1, unReseau.nbNeurone do
        local xT = CONSTANTS.DISPLAY.ANCHOR_X_HIDDEN + (CONSTANTS.DISPLAY.HIDDEN_SIZE + 1) * ((i - 1) % CONSTANTS.DISPLAY.HIDDEN_PER_ROW)
        local yT = CONSTANTS.DISPLAY.ANCHOR_Y_HIDDEN + (CONSTANTS.DISPLAY.HIDDEN_SIZE + 1) * math.floor((i - 1) / CONSTANTS.DISPLAY.HIDDEN_PER_ROW)
        local indice = i + CONSTANTS.INPUT_COUNT + CONSTANTS.OUTPUT_COUNT

        gui.drawRectangle(xT, yT, CONSTANTS.DISPLAY.HIDDEN_SIZE, CONSTANTS.DISPLAY.HIDDEN_SIZE, "black", "white")
        lesPositions[indice] = {x = xT + CONSTANTS.DISPLAY.HIDDEN_SIZE / 2, y = yT + CONSTANTS.DISPLAY.HIDDEN_SIZE / 2}
    end

    for _, connexion in ipairs(unReseau.lesConnexions) do
        if connexion.actif then
            local pixel = connexion.poids > 0 and 255 or 0
            local alpha = connexion.allume and 255 or 25
            local couleur = forms.createcolor(pixel, pixel, pixel, alpha)

            gui.drawLine(lesPositions[connexion.entree].x, lesPositions[connexion.entree].y,
                         lesPositions[connexion.sortie].x, lesPositions[connexion.sortie].y,
                         couleur)
        end
    end
end

return {
    dessinerLesInfos = dessinerLesInfos,
    dessinerUnReseau = dessinerUnReseau
}
