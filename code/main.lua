-- Chargement des modules
local constant = require("./controllers/constant")
local display = require("./controllers/display")
local event_handlers = require("./controllers/event_handlers")
local file_manager = require("./controllers/file_manager")
local game_logic = require("./controllers/game_logic")
local interaction = require("./controllers/interaction")
local network = require("./controllers/network")
local neuron = require("./controllers/neuron")
local population = require("./controllers/population")
local species = require("./controllers/species")
local ui_manager = require("./controllers/ui_manager")
local utils = require("./controllers/utils")

-- Fonctions principales
local function initialiser()
    console.clear()
    math.randomseed(os.time())

    if gameinfo.getromname() ~= NOM_JEU then
        console.log("Mauvaise ROM (actuellement " .. gameinfo.getromname() .. "), fonctionne uniquement avec " .. NOM_JEU)
        return false
    else
        console.log("Lancement du script")
        return true
    end
end

-- Script principal
if initialiser() then
    creerUI()
    gererPopulation()
    lancerNiveau()

    while true do
        gererAffichage()
        miseAJour()
        gererGeneration()
        afficherInformations()
        emu.frameadvance()
        
    end

end
