local CONSTANTS = require("./controllers/constant")
local utils = require("./controllers/utils")
local network = require("./controllers/network")
local neuron = require("./controllers/neuron")

-- Crée une nouvelle espèce
local function newEspece()
    return {
        nbEnfant = 0,
        fitnessMoyenne = 0,
        fitnessMax = 0,
        lesReseaux = {}
    }
end

-- Mutate the weights of the connections in a network
local function mutationPoidsConnexions(unReseau)
    for _, connexion in ipairs(unReseau.lesConnexions) do
        if connexion.actif then
            if math.random() < CONSTANTS.MUTATION.CONNECTION_RESET_CHANCE then
                connexion.poids = utils.genererPoids()
            else
                connexion.poids = connexion.poids + (math.random() >= 0.5 and -CONSTANTS.MUTATION.CONNECTION_WEIGHT_ADDITION or CONSTANTS.MUTATION.CONNECTION_WEIGHT_ADDITION)
            end
        end
    end
end

-- Add a new connection to a network
local function mutationAjouterConnexion(unReseau)
    local neurones = {}
    for _, neurone in ipairs(unReseau.lesNeurones) do
        table.insert(neurones, math.random(#neurones + 1), neurone)
    end

    for i = 1, #neurones do
        for j = 1, #neurones do
            if i ~= j then
                local neurone1 = neurones[i]
                local neurone2 = neurones[j]

                if (neurone1.type == "input" and neurone2.type == "output") or
                   (neurone1.type == "hidden" and neurone2.type == "hidden") or
                   (neurone1.type == "hidden" and neurone2.type == "output") then
                    local dejaConnexion = false
                    for _, connexion in ipairs(unReseau.lesConnexions) do
                        if connexion.entree == neurone1.id and connexion.sortie == neurone2.id then
                            dejaConnexion = true
                            break
                        end
                    end

                    if not dejaConnexion then
                        network.ajouterConnexion(unReseau, neurone1.id, neurone2.id)
                        return
                    end
                end
            end
        end
    end

    console.log("Impossible de créer une nouvelle connexion")
end

-- Add a new neuron to a network
local function mutationAjouterNeurone(unReseau)
    if #unReseau.lesConnexions == 0 then
        console.log("Impossible d'ajouter un neurone sans connexion existante")
        return
    end

    if unReseau.nbNeurone >= CONSTANTS.MAX_NEURON_COUNT then
        console.log("Nombre maximum de neurones atteint")
        return
    end

    local connexions = {}
    for i = 1, #unReseau.lesConnexions do
        connexions[i] = i
    end

    for i = 1, #connexions do
        local index = math.random(#connexions)
        local connexion = unReseau.lesConnexions[connexions[index]]
        if connexion.actif then
            connexion.actif = false
            unReseau.nbNeurone = unReseau.nbNeurone + 1
            local newNeuroneId = unReseau.nbNeurone + CONSTANTS.INPUT_COUNT + CONSTANTS.OUTPUT_COUNT
            neuron.ajouterNeurone(unReseau, newNeuroneId, "hidden", 1)
            network.ajouterConnexion(unReseau, connexion.entree, newNeuroneId, utils.genererPoids())
            network.ajouterConnexion(unReseau, newNeuroneId, connexion.sortie, utils.genererPoids())
            return
        end
    end
end

-- Perform mutations on a network
local function mutation(unReseau)
    local random = math.random()
    if random < CONSTANTS.MUTATION.WEIGHT_MUTATION_CHANCE then
        mutationPoidsConnexions(unReseau)
    end
    if random < CONSTANTS.MUTATION.CONNECTION_MUTATION_CHANCE then
        mutationAjouterConnexion(unReseau)
    end
    if random < CONSTANTS.MUTATION.NEURON_MUTATION_CHANCE then
        mutationAjouterNeurone(unReseau)
    end
end

return {
    newEspece = newEspece,
    mutationPoidsConnexions = mutationPoidsConnexions,
    mutationAjouterConnexion = mutationAjouterConnexion,
    mutationAjouterNeurone = mutationAjouterNeurone,
    mutation = mutation
}
