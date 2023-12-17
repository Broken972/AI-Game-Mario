-- Ajoute une connexion entre 2 neurones pas déjà connectés entre eux
-- Ça peut ne pas marcher si aucun neurone n'est connectable entre eux (uniquement si beaucoup de connexions)
function mutationAjouterConnexion(unReseau)
    local liste = {}

    -- Randomisation + copies des neurones dans une liste
    for i, v in ipairs(unReseau.lesNeurones) do
        local pos = math.random(1, #liste + 1)
        table.insert(liste, pos, v)
    end

    -- Recherche des neurones sans connexion et création d'une connexion si possible
    local traitement = false
    for i = 1, #liste do
        if traitement then break end

        for j = 1, #liste do
            if i == j then goto continue end

            local neurone1 = liste[i]
            local neurone2 = liste[j]

            if (neurone1.type == "input" and neurone2.type == "output") or
               (neurone1.type == "hidden" and neurone2.type == "hidden") or
               (neurone1.type == "hidden" and neurone2.type == "output") then
                -- Vérification de l'existence d'une connexion entre les deux neurones
                local dejaConnexion = false
                for k = 1, #unReseau.lesConnexions do
                    local connexion = unReseau.lesConnexions[k]
                    if connexion.entree == neurone1.id and connexion.sortie == neurone2.id then
                        dejaConnexion = true
                        break
                    end
                end

                if not dejaConnexion then
                    -- Nouvelle connexion, traitement terminé
                    traitement = true
                    ajouterConnexion(unReseau, neurone1.id, neurone2.id)
                    break
                end
            end

            ::continue::
        end
    end

    if not traitement then
        console.log("impossible de créer une nouvelle connexion")
    end
end




-- renvoie les inputs, sont créées en fonction d'où est mario
function getLesInputs()
	local lesInputs = {}
	for i = 1, NB_TILE_W, 1 do
		for j = 1, NB_TILE_H, 1 do
			lesInputs[getIndiceLesInputs(i, j)] = 0
		end
	end
	
	local lesSprites = getLesSprites()
	for i = 1, #lesSprites, 1 do
		local input = convertirPositionPourInput(getLesSprites()[i])
		if input.x > 0 and input.x < (TAILLE_VUE_W / TAILLE_TILE) + 1  then
			lesInputs[getIndiceLesInputs(input.x, input.y)] = -1
		end
	end

	

	local lesTiles = getLesTiles()
	for i = 1, NB_TILE_W, 1 do
		for j = 1, NB_TILE_H, 1 do
			local indice = getIndiceLesInputs(i, j)
			if lesTiles[indice] ~= 0 then
				lesInputs[indice] = lesTiles[indice]
			end
		end
	end


	return lesInputs
end

-- relance le niveau et reset tout pour le nouvel individu
function lancerNiveau()
	savestate.load(NOM_SAVESTATE)
	marioBase = getPositionMario()
	niveauFini = false
	nbFrameStop = 0
end

-- Appelle une des mutations aléatoirement en fonction des constantes
function mutation(unReseau)
    local random = math.random()
    
    -- Mutation des poids des connexions en fonction de CHANCE_MUTATION_POIDS
    if random < CHANCE_MUTATION_POIDS then
        mutationPoidsConnexions(unReseau)
    end
    
    -- Ajout d'une connexion en fonction de CHANCE_MUTATION_CONNEXION
    if random < CHANCE_MUTATION_CONNEXION then
        mutationAjouterConnexion(unReseau)
    end
    
    -- Ajout d'un neurone en fonction de CHANCE_MUTATION_NEURONE
    if random < CHANCE_MUTATION_NEURONE then
        mutationAjouterNeurone(unReseau)
    end
end

-- mets à jour un réseau de neurone avec ce qu'il y a a l'écran. A appeler à chaque frame quand on en test un reseau
function majReseau(unReseau, marioBase)
	local mario = getPositionMario()
	

	-- niveau fini ?
	if not niveauFini and memory.readbyte(0x0100) == 12 then
		unReseau.fitness = FITNESS_LEVEL_FINI -- comme ça l'espece de cette population va dominer les autres
		niveauFini = true
	-- sinon augmentation de la fitness classique (quand mario va à gauche)
	elseif marioBase.x < mario.x then
		unReseau.fitness = unReseau.fitness + (mario.x - marioBase.x)
		marioBase.x = mario.x
	end

	-- mise à jour des inputs
	lesInputs = getLesInputs()
	for i = 1, NB_INPUT, 1 do
		unReseau.lesNeurones[i].valeur = lesInputs[i]
	end
end

function niveauReussi()
	console.log("Le niveau est réussi ! Arrêt du script.")
	terminerScript() -- Nettoyez avant de quitter.
	os.exit()
end