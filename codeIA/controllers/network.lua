local CONSTANTS = require("./controllers/constant")
local utils = require("./controllers/utils")
local neuron = require("./controllers/neuron")

local function newConnexion()
    return {
        entree = 0,
        sortie = 0,
        actif = true,
        poids = 0,
        innovation = 0,
        allume = false
    }
end

local function newReseau()
    local reseau = {
        nbNeurone = 0,
        fitness = 1,
        idEspeceParent = 0,
        lesNeurones = {},
        lesConnexions = {}
    }
    for j = 1, CONSTANTS.INPUT_COUNT do
        neuron.ajouterNeurone(reseau, j, "input", 1)
    end

    for j = CONSTANTS.INPUT_COUNT + 1, CONSTANTS.INPUT_COUNT + CONSTANTS.OUTPUT_COUNT do
        neuron.ajouterNeurone(reseau, j, "output", 0)
    end

    return reseau
end

local function ajouterConnexion(unReseau, entree, sortie, poids)
    if unReseau.lesNeurones[entree].id == 0 then
        console.log("Connexion avec l'entrée " .. entree .. " n'est pas initialisée ?")
    elseif unReseau.lesNeurones[sortie].id == 0 then
        console.log("Connexion avec la sortie " .. sortie .. " n'est pas initialisée ?")
    else
        local connexion = newConnexion()
        connexion.actif = true
        connexion.entree = entree
        connexion.sortie = sortie
        connexion.poids = utils.genererPoids()
        connexion.innovation = CONSTANTS.GLOBALS.innovation_number
        table.insert(unReseau.lesConnexions, connexion)
        CONSTANTS.GLOBALS.innovation_number = CONSTANTS.GLOBALS.innovation_number + 1
    end
end

local function getDiffPoids(unReseau1, unReseau2)
    local nbConnexion = 0
    local total = 0
    for _, conn1 in ipairs(unReseau1.lesConnexions) do
        for _, conn2 in ipairs(unReseau2.lesConnexions) do
            if conn1.innovation == conn2.innovation then
                nbConnexion = nbConnexion + 1
                total = total + math.abs(conn1.poids - conn2.poids)
            end
        end
    end

    if nbConnexion == 0 then
        return 100000
    end

    return total / nbConnexion
end

local function getDisjoint(unReseau1, unReseau2)
    local nbPareil = 0
    for _, conn1 in ipairs(unReseau1.lesConnexions) do
        for _, conn2 in ipairs(unReseau2.lesConnexions) do
            if conn1.innovation == conn2.innovation then
                nbPareil = nbPareil + 1
            end
        end
    end

    return #unReseau1.lesConnexions + #unReseau2.lesConnexions - 2 * nbPareil
end

local function getScore(unReseauTest, unReseauRep)
    return (CONSTANTS.SPECIES.EXCESS_COEF * getDisjoint(unReseauTest, unReseauRep)) /
           (math.max(#unReseauTest.lesConnexions + #unReseauRep.lesConnexions, 1)) +
           CONSTANTS.SPECIES.WEIGHT_DIFF_COEF * getDiffPoids(unReseauTest, unReseauRep)
end

local function feedForward(unReseau)
    for _, conn in ipairs(unReseau.lesConnexions) do
        if conn.actif then
            local neurone = unReseau.lesNeurones[conn.sortie]
            neurone.valeur = 0
            neurone.allume = false
        end
    end

    for _, conn in ipairs(unReseau.lesConnexions) do
        if conn.actif then
            local sortieNeurone = unReseau.lesNeurones[conn.sortie]
            local avantTraitement = sortieNeurone.valeur
            sortieNeurone.valeur = unReseau.lesNeurones[conn.entree].valeur * conn.poids + sortieNeurone.valeur

            conn.allume = avantTraitement ~= sortieNeurone.valeur
        end
    end
end

local function crossover(unReseau1, unReseau2)
    local leReseau = utils.copier((unReseau1.fitness >= unReseau2.fitness) and unReseau1 or unReseau2)

    for _, conn in ipairs(unReseau2.lesConnexions) do
        if unReseau1.lesConnexions[conn.innovation] and conn.actif and math.random() > 0.5 then
            leReseau.lesConnexions[conn.innovation] = conn
        end
    end

    leReseau.fitness = 1
    return leReseau
end

local function sauvegarderUnReseau(unReseau, fichier)
    fichier:write(unReseau.nbNeurone .. "\n")
    fichier:write(#unReseau.lesConnexions .. "\n")
    fichier:write(unReseau.fitness .. "\n")

    for i = 1, unReseau.nbNeurone do
        local indice = CONSTANTS.INPUT_COUNT + CONSTANTS.OUTPUT_COUNT + i
        fichier:write(unReseau.lesNeurones[indice].id .. "\n")
    end

    for _, conn in ipairs(unReseau.lesConnexions) do
        fichier:write((conn.actif and 1 or 0) .. "\n")
        fichier:write(conn.entree .. "\n")
        fichier:write(conn.sortie .. "\n")
        fichier:write(conn.poids .. "\n")
        fichier:write(conn.innovation .. "\n")
    end
end

local function chargerUnReseau(fichier)
    local unReseau = newReseau()
    unReseau.nbNeurone = tonumber(fichier:read("*line"))
    local nbConnexion = tonumber(fichier:read("*line"))
    unReseau.fitness = tonumber(fichier:read("*line"))

    for i = 1, unReseau.nbNeurone do
        local neurone = neuron.newNeurone()
        neurone.id = tonumber(fichier:read("*line"))
        neurone.type = "hidden"
        table.insert(unReseau.lesNeurones, neurone)
    end

    for i = 1, nbConnexion do
        local conn = newConnexion()
        conn.actif = tonumber(fichier:read("*line")) == 1
        conn.entree = tonumber(fichier:read("*line"))
        conn.sortie = tonumber(fichier:read("*line"))
        conn.poids = tonumber(fichier:read("*line"))
        conn.innovation = tonumber(fichier:read("*line"))
        table.insert(unReseau.lesConnexions, conn)
    end

    return unReseau
end

local function majReseau(unReseau, marioBase)
    local mario = utils.getPositionMario()

    if not CONSTANTS.GLOBALS.level_finished and memory.readbyte(0x0100) == 12 then
        unReseau.fitness = CONSTANTS.FITNESS_LEVEL_FINISHED
        CONSTANTS.GLOBALS.level_finished = true
    elseif marioBase.x < mario.x then
        unReseau.fitness = unReseau.fitness + (mario.x - marioBase.x)
        marioBase.x = mario.x
    end

    local lesInputs = utils.getLesInputs()
    for i = 1, CONSTANTS.INPUT_COUNT do
        unReseau.lesNeurones[i].valeur = lesInputs[i]
    end
end

return {
    newConnexion = newConnexion,
    newReseau = newReseau,
    ajouterConnexion = ajouterConnexion,
    getDiffPoids = getDiffPoids,
    getDisjoint = getDisjoint,
    getScore = getScore,
    feedForward = feedForward,
    crossover = crossover,
    sauvegarderUnReseau = sauvegarderUnReseau,
    chargerUnReseau = chargerUnReseau,
    majReseau = majReseau
}
