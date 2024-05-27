local CONSTANTS = require("./controllers/constant")
local network = require("./controllers/network")
local utils = require("./controllers/utils")
local mutation = require("./controllers/mutation")

-- Crée une nouvelle population
local function newPopulation()
    local population = {}
    for i = 1, CONSTANTS.POPULATION_SIZE do
        table.insert(population, network.newReseau())
    end
    return population
end

-- Trie la population en espèces
local function trierPopulation(laPopulation)
    local lesEspeces = {mutation.newEspece()}
    table.insert(lesEspeces[1].lesReseaux, utils.copier(laPopulation[#laPopulation]))

    for i = 1, #laPopulation - 1 do
        local trouve = false
        for _, espece in ipairs(lesEspeces) do
            local indice = math.random(1, #espece.lesReseaux)
            local rep = espece.lesReseaux[indice]
            if network.getScore(laPopulation[i], rep) < CONSTANTS.SPECIES.DIFFERENCE_THRESHOLD then
                table.insert(espece.lesReseaux, utils.copier(laPopulation[i]))
                trouve = true
                break
            end
        end
        if not trouve then
            local nouvelleEspece = mutation.newEspece()
            table.insert(nouvelleEspece.lesReseaux, utils.copier(laPopulation[i]))
            table.insert(lesEspeces, nouvelleEspece)
        end
    end

    return lesEspeces
end

-- Choisit un parent pour la reproduction
local function choisirParent(uneEspece)
    if #uneEspece == 0 then
        console.log("uneEspece vide dans choisir parent ??")
        return nil
    end
    if #uneEspece == 1 then
        return uneEspece[1]
    end

    local fitnessTotal = 0
    for _, reseau in ipairs(uneEspece) do
        fitnessTotal = fitnessTotal + reseau.fitness
    end

    local limite = math.random() * fitnessTotal
    local total = 0
    for _, reseau in ipairs(uneEspece) do
        total = total + reseau.fitness
        if total >= limite then
            return utils.copier(reseau)
        end
    end
    console.log("impossible de trouver un parent ?")
    return nil
end

-- Crée une nouvelle génération
local function nouvelleGeneration(laPopulation, lesEspeces)
    local laNouvellePopulation = newPopulation()
    local nbIndividuACreer = CONSTANTS.POPULATION_SIZE
    local indiceNouvelleEspece = 1

    -- Déterminer le fitness maximum dans la population actuelle
    local fitnessMaxPop = 0
    for _, reseau in ipairs(laPopulation) do
        if reseau.fitness > fitnessMaxPop then
            fitnessMaxPop = reseau.fitness
        end
    end

    -- Déterminer le fitness maximum dans les populations précédentes
    local fitnessMaxAncPop = 0
    local ancienPlusFort
    for _, anciennePop in ipairs(CONSTANTS.GLOBALS.previous_populations) do
        for _, reseau in ipairs(anciennePop) do
            if reseau.fitness > fitnessMaxAncPop then
                fitnessMaxAncPop = reseau.fitness
                ancienPlusFort = reseau
            end
        end
    end

    -- Si une ancienne population est plus forte, utiliser l'ancien plus fort pour la nouvelle génération
    if fitnessMaxAncPop > fitnessMaxPop then
        for _, espece in ipairs(lesEspeces) do
            for i = 1, #espece.lesReseaux do
                espece.lesReseaux[i] = utils.copier(ancienPlusFort)
            end
        end
        console.log("Mauvaise population, je reprends la meilleure et ça redevient la base de la nouvelle pop")
    end

    table.insert(CONSTANTS.GLOBALS.previous_populations, laPopulation)

    local nbIndividuTotal = 0
    local fitnessMoyenneGlobal = 0
    local leMeilleur = network.newReseau()

    for _, espece in ipairs(lesEspeces) do
        espece.fitnessMoyenne = 0
        espece.fitnessMax = 0

        for _, reseau in ipairs(espece.lesReseaux) do
            espece.fitnessMoyenne = espece.fitnessMoyenne + reseau.fitness
            fitnessMoyenneGlobal = fitnessMoyenneGlobal + reseau.fitness
            nbIndividuTotal = nbIndividuTotal + 1

            if reseau.fitness > espece.fitnessMax then
                espece.fitnessMax = reseau.fitness
                if reseau.fitness > leMeilleur.fitness then
                    leMeilleur = utils.copier(reseau)
                end
            end
        end
        espece.fitnessMoyenne = espece.fitnessMoyenne / #espece.lesReseaux
    end

    if leMeilleur.fitness == CONSTANTS.FITNESS_LEVEL_FINISHED then
        for _, espece in ipairs(lesEspeces) do
            for i = 1, #espece.lesReseaux do
                espece.lesReseaux[i] = utils.copier(leMeilleur)
            end
        end
        fitnessMoyenneGlobal = leMeilleur.fitness
    else
        fitnessMoyenneGlobal = fitnessMoyenneGlobal / nbIndividuTotal
    end

    table.sort(lesEspeces, function(e1, e2) return e1.fitnessMax > e2.fitnessMax end)

    for _, espece in ipairs(lesEspeces) do
        local nbIndividuEspece = math.ceil(#espece.lesReseaux * espece.fitnessMoyenne / fitnessMoyenneGlobal)
        nbIndividuACreer = nbIndividuACreer - nbIndividuEspece
        if nbIndividuACreer < 0 then
            nbIndividuEspece = nbIndividuEspece + nbIndividuACreer
            nbIndividuACreer = 0
        end
        espece.nbEnfant = nbIndividuEspece

        for j = 1, nbIndividuEspece do
            if indiceNouvelleEspece > CONSTANTS.POPULATION_SIZE then
                break
            end

            local unReseau = network.crossover(choisirParent(espece.lesReseaux), choisirParent(espece.lesReseaux))

            if fitnessMoyenneGlobal ~= CONSTANTS.FITNESS_LEVEL_FINISHED then
                mutation.mutation(unReseau)
            end

            unReseau.idEspeceParent = _
            laNouvellePopulation[indiceNouvelleEspece] = utils.copier(unReseau)
            laNouvellePopulation[indiceNouvelleEspece].fitness = 1
            indiceNouvelleEspece = indiceNouvelleEspece + 1
        end

        if indiceNouvelleEspece > CONSTANTS.POPULATION_SIZE then
            break
        end
    end

    for i = #lesEspeces, 1, -1 do
        if lesEspeces[i].nbEnfant == 0 then
            table.remove(lesEspeces, i)
        end
    end

    return laNouvellePopulation
end

-- Sauvegarde la population actuelle dans un fichier
local function sauvegarderPopulation(laPopulation, estFini)
    local chemin = utils.getNomFichierSauvegarde()
    if estFini then
        chemin = "FINI " .. chemin
    end

    local fichier = io.open(chemin, "w+")
    io.output(fichier)

    io.write(CONSTANTS.GLOBALS.generation_number .. "\n")
    io.write(CONSTANTS.GLOBALS.innovation_number .. "\n")
    for _, reseau in ipairs(laPopulation) do
        network.sauvegarderUnReseau(reseau, fichier)
    end

    local lePlusFort = network.newReseau()
    for _, reseau in ipairs(laPopulation) do
        if reseau.fitness > lePlusFort.fitness then
            lePlusFort = utils.copier(reseau)
        end
    end

    for _, anciennePop in ipairs(CONSTANTS.GLOBALS.previous_populations) do
        for _, reseau in ipairs(anciennePop) do
            if reseau.fitness > lePlusFort.fitness then
                lePlusFort = utils.copier(reseau)
            end
        end
    end
    network.sauvegarderUnReseau(lePlusFort, fichier)
    io.close(fichier)

    console.log("Sauvegarde terminée dans le fichier " .. chemin)
end

-- Charge une population depuis un fichier
local function chargerPopulation(chemin)
    if not chemin:find("%.pop$") then
        console.log("Le fichier " .. chemin .. " n'est pas du bon format (.pop)")
        return nil
    end

    local fichier = io.open(chemin, "r")
    if not fichier then
        console.log("Impossible d'ouvrir le fichier " .. chemin)
        return nil
    end

    io.input(fichier)
    local laPopulation = {}

    CONSTANTS.GLOBALS.generation_number = tonumber(io.read("*line"))
    CONSTANTS.GLOBALS.innovation_number = tonumber(io.read("*line"))

    for i = 1, CONSTANTS.POPULATION_SIZE do
        local reseau = network.chargerUnReseau(fichier)
        reseau.fitness = 1
        table.insert(laPopulation, reseau)
    end

    CONSTANTS.GLOBALS.previous_populations = {utils.copier(laPopulation)}
    CONSTANTS.GLOBALS.previous_populations[1][1] = network.chargerUnReseau(fichier)

    console.log("Plus fort chargé")
    console.log(CONSTANTS.GLOBALS.previous_populations[1][1])

    if CONSTANTS.GLOBALS.previous_populations[1][1].fitness == CONSTANTS.FITNESS_LEVEL_FINISHED then
        for i = 1, CONSTANTS.POPULATION_SIZE do
            laPopulation[i] = utils.copier(CONSTANTS.GLOBALS.previous_populations[1][1])
        end
    end

    io.close(fichier)
    console.log("Chargement terminé de " .. chemin)

    return laPopulation
end

return {
    newPopulation = newPopulation,
    trierPopulation = trierPopulation,
    choisirParent = choisirParent,
    nouvelleGeneration = nouvelleGeneration,
    sauvegarderPopulation = sauvegarderPopulation,
    chargerPopulation = chargerPopulation
}
