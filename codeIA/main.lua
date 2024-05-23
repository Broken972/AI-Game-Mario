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

console.clear()
if gameinfo.getromname() ~= constants.GAME_NAME then
    console.log("Mauvaise ROM (actuellement " .. gameinfo.getromname() .. "), marche uniquement avec " .. constants.GAME_NAME)
else
    console.log("Lancement du script")
    math.randomseed(os.time())

    lancerNiveau()

    local form = forms.newform(constants.FORM_WIDTH, constants.FORM_HEIGHT, "Informations")
    local labelInfo = forms.label(form, "a maj", 0, 0, 350, 220)
    local estAccelere = forms.checkbox(form, "Accelerer", 10, 220)
    local estAfficheReseau = forms.checkbox(form, "Afficher reseau", 10, 240)
    local estAfficheInfo = forms.checkbox(form, "Afficher bandeau", 10, 260)
    forms.button(form, "Pause", utils.traitementPause, 10, 285)
    forms.button(form, "Sauvegarder", utils.activerSauvegarde, 10, 315)
    forms.button(form, "Charger", utils.activerChargement, 100, 315)

    constants.GLOBALS.population = population.newPopulation()

    for i = 1, #constants.GLOBALS.population do
        mutation.mutation(constants.GLOBALS.population[i])
    end

    for i = 2, #constants.GLOBALS.population do
        constants.GLOBALS.population[i] = utils.copier(constants.GLOBALS.population[1])
        mutation.mutation(constants.GLOBALS.population[i])
    end

    constants.GLOBALS.species_list = population.trierPopulation(constants.GLOBALS.population)
    constants.GLOBALS.population = population.nouvelleGeneration(constants.GLOBALS.population, constants.GLOBALS.species_list)

    while true do
        local fitnessAvant = constants.GLOBALS.population[constants.GLOBALS.population_id].fitness
        local nettoyer = true

        if forms.ischecked(estAccelere) then
            emu.limitframerate(false)
        else
            emu.limitframerate(true)
        end

        if forms.ischecked(estAfficheReseau) then
            display.dessinerUnReseau(constants.GLOBALS.population[constants.GLOBALS.population_id])
            nettoyer = false
        end

        if forms.ischecked(estAfficheInfo) then
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
                    if not constants.GLOBALS.level_finished_saved then
                        for i = 1, #constants.GLOBALS.population do
                            if constants.GLOBALS.population[i].fitness == constants.FITNESS_LEVEL_FINISHED then
                                population.sauvegarderPopulation(constants.GLOBALS.population, true)
                                constants.GLOBALS.level_finished_saved = true
                                console.log("Niveau fini après " .. constants.GLOBALS.generation_number .. " générations !")
                            end
                        end
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

        local str = "Generation " .. constants.GLOBALS.generation_number .. " Fitness maximal: " ..
                    constants.GLOBALS.max_fitness .. "\nInformations sur l'individu actuel:\n" ..
                    "id: " .. constants.GLOBALS.population_id .. "/" .. #constants.GLOBALS.population .. " neurones: " ..
                    #constants.GLOBALS.population[constants.GLOBALS.population_id].lesNeurones .. " connexions: " ..
                    #constants.GLOBALS.population[constants.GLOBALS.population_id].lesConnexions .. " enfant de l'espèce " ..
                    constants.GLOBALS.population[constants.GLOBALS.population_id].idEspeceParent ..
                    "\n\nInfos sur les espèces: " ..
                    "\nIl y a " .. #constants.GLOBALS.species_list .. " espèce(s) "
        for i = 1, #constants.GLOBALS.species_list do
            str = str .. "\nespèce " .. i .. " a fait " .. constants.GLOBALS.species_list[i].nbEnfant .. " enfant(s)"  .. " (fitness max " .. constants.GLOBALS.species_list[i].fitnessMax .. ") "
        end
        forms.settext(labelInfo, str)
    end
end
