-- Crée un nouveau neurone
function newNeurone()
    local neurone = {}
    
    neurone.valeur = 0         -- Valeur initiale du neurone
    neurone.id = 0             -- Identifiant non initialisé si égal à 0, doit être égal à l'indice du neurone dans lesNeurones du réseau
    neurone.type = ""          -- Type de neurone (input, hidden, output), doit être défini plus tard
    
    return neurone
end

-- applique les boutons aux joypad de l'emulateur avec un reseau de neurone
function appliquerLesBoutons(unReseau)
	local lesBoutonsT = {}
	for i = 1, NB_OUTPUT, 1 do
		lesBoutonsT[lesBoutons[i].nom] = sigmoid(unReseau.lesNeurones[NB_INPUT + i].valeur)
	end

	-- c'est pour que droit est la prio sur la gauche
	if lesBoutonsT["P1 Left"] and lesBoutonsT["P1 Right"] then
		lesBoutonsT["P1 Left"] = false
	end
	joypad.set(lesBoutonsT)
end

-- Ajoute une connexion à un réseau de neurones
function ajouterConnexion(unReseau, entree, sortie, poids)
    -- Vérifie si les neurones de la connexion existent bien
    if unReseau.lesNeurones[entree].id == 0 then
        console.log("La connexion avec l'entrée " .. entree .. " n'est pas initialisée ?")
        return
    end
    if unReseau.lesNeurones[sortie].id == 0 then
        console.log("La connexion avec la sortie " .. sortie .. " n'est pas initialisée ?")
        return
    end
    
    local connexion = newConnexion()
    connexion.actif = true
    connexion.entree = entree
    connexion.sortie = sortie
    connexion.poids = genererPoids()
    connexion.innovation = nbInnovation
    table.insert(unReseau.lesConnexions, connexion)
    nbInnovation = nbInnovation + 1
end

-- Crée un nouveau réseau de neurones
function newReseau()
    local reseau = {
        nbNeurone = 0,         -- Taille des neurones ajoutés par l'algorithme (hors input et output)
        fitness = 1,           -- Beaucoup de divisions, pour éviter de faire l'irréparable
        idEspeceParent = 0,
        lesNeurones = {},      -- Liste des neurones du réseau
        lesConnexions = {}     -- Liste des connexions du réseau
    }

    -- Ajoute les neurones d'entrée
    for j = 1, NB_INPUT, 1 do
        ajouterNeurone(reseau, j, "input", 1)
    end

    -- Ajoute les neurones de sortie
    for j = NB_INPUT + 1, NB_INPUT + NB_OUTPUT, 1 do
        ajouterNeurone(reseau, j, "output", 0)
    end

    return reseau
end

-- Modifie les connexions d'un réseau de neurones
function mutationPoidsConnexions(unReseau)
    for i = 1, #unReseau.lesConnexions, 1 do
        local connexion = unReseau.lesConnexions[i]
        if connexion.actif then
            if math.random() < CHANCE_MUTATION_RESET_CONNEXION then
                connexion.poids = genererPoids()
            else
                local ajustement = (math.random() >= 0.5) and -POIDS_CONNEXION_MUTATION_AJOUT or POIDS_CONNEXION_MUTATION_AJOUT
                connexion.poids = connexion.poids + ajustement
            end
        end
    end
end

-- Retourne la différence de poids de 2 réseaux de neurones (uniquement pour les mêmes innovations)
function getDiffPoids(unReseau1, unReseau2)
    local nbConnexion = 0
    local total = 0
    for i = 1, #unReseau1.lesConnexions, 1 do
        for j = 1, #unReseau2.lesConnexions, 1 do
            if unReseau1.lesConnexions[i].innovation == unReseau2.lesConnexions[j].innovation then
                nbConnexion = nbConnexion + 1
                total = total + math.abs(unReseau1.lesConnexions[i].poids - unReseau2.lesConnexions[j].poids)
            end
        end
    end

    -- Si aucune connexion en commun, c'est qu'ils sont trop différents
    -- De plus, si on laisse comme ça, on va diviser par 0 et ça causera des problèmes
    if nbConnexion == 0 then
        return 100000
    end

    return total / nbConnexion
end

-- Retourne le nombre de connexions qui n'ont aucun rapport entre les 2 réseaux
function getDisjoint(unReseau1, unReseau2)
    local nbPareil = 0
    for i = 1, #unReseau1.lesConnexions, 1 do
        for j = 1, #unReseau2.lesConnexions, 1 do
            if unReseau1.lesConnexions[i].innovation == unReseau2.lesConnexions[j].innovation then
                nbPareil = nbPareil + 1
            end
        end
    end

    -- Retourne le nombre total de connexions disjointes
    return #unReseau1.lesConnexions + #unReseau2.lesConnexions - 2 * nbPareil
end

-- applique les connexions d'un réseau de neurone en modifiant la valeur des neurones de sortie
function feedForward(unReseau)
	-- avant de continuer, je reset à 0 les neurones de sortie
	for i = 1, #unReseau.lesConnexions, 1 do
		if unReseau.lesConnexions[i].actif then
			unReseau.lesNeurones[unReseau.lesConnexions[i].sortie].valeur = 0
			unReseau.lesNeurones[unReseau.lesConnexions[i].sortie].allume = false
		end
	end


	for i = 1, #unReseau.lesConnexions, 1 do
		if unReseau.lesConnexions[i].actif then
			local avantTraitement = unReseau.lesNeurones[unReseau.lesConnexions[i].sortie].valeur
			unReseau.lesNeurones[unReseau.lesConnexions[i].sortie].valeur = 
							unReseau.lesNeurones[unReseau.lesConnexions[i].entree].valeur * 
							unReseau.lesConnexions[i].poids + 
							unReseau.lesNeurones[unReseau.lesConnexions[i].sortie].valeur
			
			-- on ""allume"" le lien si la connexion a fait une modif
			if avantTraitement ~= unReseau.lesNeurones[unReseau.lesConnexions[i].sortie].valeur then
				unReseau.lesConnexions[i].allume = true
			else 
				unReseau.lesConnexions[i].allume = false
			end
		end
	end
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

