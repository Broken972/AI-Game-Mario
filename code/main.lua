local constants = require("./controllers/constant")
local display = require("./controllers/display")
local mutation = require("./controllers/mutation")
local network = require("./controllers/network")
local neuron = require("./controllers/neuron")
local population = require("./controllers/population")
local utils = require("./controllers/utils")

local function lancerNiveau()
    savestate.load(constants.SAVESTATE_NAME)
    constants.GLOBALS.mario_base_position = utils.getPositionMario()
    constants.GLOBALS.level_finished = false
    constants.GLOBALS.frame_stop_count = 0
end

local function activerSauvegarde()
    population.sauvegarderPopulation(constants.GLOBALS.population, false)
end

local function activerChargement()
    local chemin = forms.openfile()
    if chemin ~= "" then
        local laPopulationT = population.chargerPopulation(chemin)
        if laPopulationT then
            constants.GLOBALS.population = utils.copier(laPopulationT)
            constants.GLOBALS.population_id = 1
            lancerNiveau()
        end
    end
end

local function sauvegarderMeilleureRun()
    local chemin = "best_run_" .. os.date("%Y%m%d%H%M%S") .. ".state"
    savestate.save(chemin)
    console.log("Meilleure run sauvegardée dans le fichier " .. chemin)
end

-- Initialisation du nettoyage pour chaque génération
local function nettoyerGenerationPrecedente()
    collectgarbage("collect")  -- Appel du garbage collector
end

local function initialiserInterface()
    local form = forms.newform(constants.FORM_WIDTH, constants.FORM_HEIGHT, "Informations")
    constants.GLOBALS.label_info = forms.label(form, "a maj", 0, 0, 350, 220)
    constants.GLOBALS.est_accelere = forms.checkbox(form, "Accelerer", 10, 220)
    constants.GLOBALS.est_affiche_reseau = forms.checkbox(form, "Afficher reseau", 10, 240)
    constants.GLOBALS.est_affiche_info = forms.checkbox(form, "Afficher bandeau", 10, 260)
    forms.button(form, "Pause", utils.traitementPause, 10, 285)
    forms.button(form, "Sauvegarder", activerSauvegarde, 10, 315)
    forms.button(form, "Charger", activerChargement, 100, 315)
end

local function initialiserPopulation()
    constants.GLOBALS.population = population.newPopulation()

    for i = 1, #constants.GLOBALS.population do
        if i == 1 then
            mutation.mutation(constants.GLOBALS.population[i])
        else
            constants.GLOBALS.population[i] = utils.copier(constants.GLOBALS.population[1])
            mutation.mutation(constants.GLOBALS.population[i])
        end
    end
end


local function miseAJourInterface()
    local str = "Generation " .. constants.GLOBALS.generation_number .. " Fitness maximal: " ..
                constants.GLOBALS.max_fitness .. "\nInformations sur l'individu actuel:\n" ..
                "id: " .. constants.GLOBALS.population_id .. "/" .. #constants.GLOBALS.population .." neurones: " ..
                #constants.GLOBALS.population[constants.GLOBALS.population_id].lesNeurones .. " connexions: " ..
                #constants.GLOBALS.population[constants.GLOBALS.population_id].lesConnexions .. " enfant de l'espece " ..
                constants.GLOBALS.population[constants.GLOBALS.population_id].idEspeceParent ..
                "\n\nInfos sur les espèces: " ..
                "\nIl y a " .. #constants.GLOBALS.species_list .. " espèce(s) "
    for i = 1, #constants.GLOBALS.species_list do
        str = str .. "\nespece " .. i .. " a fait " .. constants.GLOBALS.species_list[i].nbEnfant .. " enfant(s)" .. " (fitness max " .. constants.GLOBALS.species_list[i].fitnessMax .. ") "
    end
    forms.settext(constants.GLOBALS.label_info, str)
end

local function verifierFinNiveau()
    if not constants.GLOBALS.level_finished_saved then
        for i = 1, #constants.GLOBALS.population do
            if constants.GLOBALS.population[i].fitness == constants.FITNESS_LEVEL_FINISHED then
                population.sauvegarderPopulation(constants.GLOBALS.population, true)
                sauvegarderMeilleureRun()
                constants.GLOBALS.level_finished_saved = true
                console.log("Niveau fini après " .. constants.GLOBALS.generation_number .. " générations !")
                return true  -- Arrêter le script
            end
        end
    end
    return false
end


console.clear()
if gameinfo.getromname() ~= constants.GAME_NAME then
    console.log("Mauvaise ROM (actuellement " .. gameinfo.getromname() .. "), marche uniquement avec " .. constants.GAME_NAME)
else
    console.log("Lancement du script")
    math.randomseed(os.time())

    lancerNiveau()
    initialiserInterface()
    initialiserPopulation()

    constants.GLOBALS.species_list = population.trierPopulation(constants.GLOBALS.population)
    constants.GLOBALS.population = population.nouvelleGeneration(constants.GLOBALS.population, constants.GLOBALS.species_list)

    while true do


        if constants.GLOBALS.population_id > #constants.GLOBALS.population then
            if verifierFinNiveau() then
                break
            end
            constants.GLOBALS.population_id = 1
            constants.GLOBALS.generation_number = constants.GLOBALS.generation_number + 1
            constants.GLOBALS.species_list = population.trierPopulation(constants.GLOBALS.population)
            constants.GLOBALS.population = population.nouvelleGeneration(constants.GLOBALS.population, constants.GLOBALS.species_list)
            constants.GLOBALS.current_frame_count = 0
            constants.GLOBALS.initial_fitness = 0
        
            -- Nettoyage à la fin de chaque génération
            nettoyerGenerationPrecedente()
        end

        local fitnessAvant = constants.GLOBALS.population[constants.GLOBALS.population_id].fitness
        local nettoyer = true

        if forms.ischecked(constants.GLOBALS.est_accelere) then
            emu.limitframerate(false)
        else
            emu.limitframerate(true)
        end

        if forms.ischecked(constants.GLOBALS.est_affiche_reseau) then
            display.dessinerUnReseau(constants.GLOBALS.population[constants.GLOBALS.population_id])
            nettoyer = false
        end

        if forms.ischecked(constants.GLOBALS.est_affiche_info) then
            display.dessinerLesInfos(constants.GLOBALS.population, constants.GLOBALS.species_list, constants.GLOBALS.generation_number)
            nettoyer = false
        end

        if nettoyer then
            gui.clearGraphics()
        end

        network.majReseau(constants.GLOBALS.population[constants.GLOBALS.population_id], constants.GLOBALS.mario_base_position)
        network.feedForward(constants.GLOBALS.population[constants.GLOBALS.population_id])
        utils.appliquerLesBoutons(constants.GLOBALS.population[constants.GLOBALS.population_id])

        if constants.GLOBALS.current_frame_count == 0 then
            constants.GLOBALS.initial_fitness = constants.GLOBALS.population[constants.GLOBALS.population_id].fitness
        end

        emu.frameadvance()
        constants.GLOBALS.current_frame_count = constants.GLOBALS.current_frame_count + 1

        if constants.GLOBALS.max_fitness < constants.GLOBALS.population[constants.GLOBALS.population_id].fitness then
            constants.GLOBALS.max_fitness = constants.GLOBALS.population[constants.GLOBALS.population_id].fitness
        end

        if fitnessAvant == constants.GLOBALS.population[constants.GLOBALS.population_id].fitness and memory.readbyte(0x13D4) == 0 then
            constants.GLOBALS.frame_stop_count = constants.GLOBALS.frame_stop_count + 1
            local nbFrameReset = constants.BASE_FRAME_RESET

            if constants.GLOBALS.initial_fitness ~= constants.GLOBALS.population[constants.GLOBALS.population_id].fitness and memory.readbyte(0x0071) ~= 9 then
                nbFrameReset = constants.PROGRESS_FRAME_RESET
            end

            if constants.GLOBALS.frame_stop_count > nbFrameReset then
                constants.GLOBALS.frame_stop_count = 0
                lancerNiveau()
                constants.GLOBALS.population_id = constants.GLOBALS.population_id + 1

                if constants.GLOBALS.population_id > #constants.GLOBALS.population then
                    if verifierFinNiveau() then
                        break
                    end
                    constants.GLOBALS.population_id = 1
                    constants.GLOBALS.generation_number = constants.GLOBALS.generation_number + 1
                    constants.GLOBALS.species_list = population.trierPopulation(constants.GLOBALS.population)
                    constants.GLOBALS.population = population.nouvelleGeneration(constants.GLOBALS.population, constants.GLOBALS.species_list)
                    constants.GLOBALS.current_frame_count = 0
                    constants.GLOBALS.initial_fitness = 0
                end
            end
        else
            constants.GLOBALS.frame_stop_count = 0
        end

        miseAJourInterface()
    end
end
