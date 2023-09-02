-- Crée un nouveau neurone
function newNeurone()
    local neurone = {}
    
    neurone.valeur = 0         -- Valeur initiale du neurone
    neurone.id = 0             -- Identifiant non initialisé si égal à 0, doit être égal à l'indice du neurone dans lesNeurones du réseau
    neurone.type = ""          -- Type de neurone (input, hidden, output), doit être défini plus tard
    
    return neurone
end

-- Ajoute un neurone à un réseau de neurones, utilisé seulement pour les neurones qui doivent exister
function ajouterNeurone(unReseau, id, type, valeur)
    if id == 0 then
        console.log("La fonction ajouterNeurone ne doit pas être utilisée avec un id == 0")
        return
    end

    local neurone = newNeurone()
    neurone.id = id
    neurone.type = type
    neurone.valeur = valeur
    table.insert(unReseau.lesNeurones, neurone)
end

-- Ajoute un neurone (couche cachée uniquement) entre 2 neurones déjà connectés. Ne peut pas marcher
-- si il n'y a pas de connexion 
function mutationAjouterNeurone(unReseau)
    if #unReseau.lesConnexions == 0 then
        console.log("Impossible d'ajouter un neurone entre 2 connexions si pas de connexion")
        return nil
    end
    
    if unReseau.nbNeurone == NB_NEURONE_MAX then
        console.log("Nombre de neurone max atteint")
        return nil
    end

    -- Randomisation de la liste des connexions
    local listeRandom = {}
    for i = 1, #unReseau.lesConnexions do
        local pos = math.random(1, #listeRandom + 1)
        table.insert(listeRandom, pos, i)
    end

    for _, indice in ipairs(listeRandom) do
        local connexion = unReseau.lesConnexions[indice]
        if connexion.actif then
            -- Désactive la connexion existante
            connexion.actif = false

            -- Ajoute un nouveau neurone caché
            unReseau.nbNeurone = unReseau.nbNeurone + 1
            local indiceNeurone = unReseau.nbNeurone + NB_INPUT + NB_OUTPUT
            ajouterNeurone(unReseau, indiceNeurone, "hidden", 1)

            -- Ajoute deux nouvelles connexions
            ajouterConnexion(unReseau, connexion.entree, indiceNeurone, genererPoids())
            ajouterConnexion(unReseau, indiceNeurone, connexion.sortie, genererPoids())

            break
        end
    end
end

