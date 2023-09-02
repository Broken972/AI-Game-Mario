-- Loading constants module
dofile("./controllers/constante.lua")

-- Loading population module
dofile("./controllers/population.lua")

-- Loading neurone module
dofile("./controllers/neurone.lua")

-- Loading connexion module
dofile("./controllers/connexion.lua")

-- Loading reseau module
-- dofile("./controllers/reseau.lua")

-- Loading espece module
-- dofile("./controllers/espece.lua")

-- Loading utils module
-- dofile("./controllers/utils.lua")

-- Loading affichage module
-- dofile("./controllers/affichage.lua")

-- Loading panel module
-- dofile("./controllers/utils.lua")
















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



-- Crée une nouvelle espèce (un regroupement de réseaux, d'individus)
function newEspece()
    local espece = {
        nbEnfant = 0,            -- Nombre d'enfants que cette espèce a créé
        fitnessMoyenne = 0,      -- Fitness moyenne de l'espèce
        fitnessMax = 0,          -- Fitness maximale atteinte par l'espèce
        lesReseaux = {}          -- Tableau qui regroupe les réseaux de l'espèce
    }

    return espece
end



-- Copie une structure de données et renvoie la copie
-- Le code original provient de http://lua-users.org/wiki/CopyTable
function copier(orig)
    local orig_type = type(orig)
    local copie

    if orig_type == 'table' then
        copie = {}
        for orig_key, orig_value in next, orig, nil do
            copie[copier(orig_key)] = copier(orig_value)
        end
        setmetatable(copie, copier(getmetatable(orig)))
    else -- number, string, boolean, etc
        copie = orig
    end

    return copie
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




-- permet d'obtenir le score d'un reseau de neurone, ce qui va le mettre dans une especes
-- rien à voir avec le fitness 
-- unReseauRep et un reseau appartenant deja a une espece 
-- et reseauTest et le reseau qui va etre testé
function getScore(unReseauTest, unReseauRep)
	return (EXCES_COEF * getDisjoint(unReseauTest, unReseauRep)) / 
		(math.max(#unReseauTest.lesConnexions + #unReseauRep.lesConnexions, 1))
		+ POIDSDIFF_COEF * getDiffPoids(unReseauTest, unReseauRep)
end

-- genere un poids aléatoire (pour les connexions) egal à 1 ou -1
function genererPoids()
	local var = 1
	if math.random() >= 0.5 then
		var = var * -1
	end
	return var
end


-- fonction d'activation
function sigmoid(x)
	local resultat = x / (1 + math.abs(x))
	if resultat >= 0.5 then
		return true
	end
	return false
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




-- Fonction pour effectuer un croisement entre deux réseaux de neurones
function crossover(unReseau1, unReseau2)
    local leReseau = newReseau()

    -- Quel est le meilleur des deux ?
    local leBon, leNul

    -- Comparaison des valeurs de fitness pour déterminer le meilleur réseau
    if unReseau1.fitness > unReseau2.fitness then
        leBon = unReseau1
        leNul = unReseau2
    else
        leBon = unReseau2
        leNul = unReseau1
    end

    -- Le nouveau réseau hérite de la majorité des attributs du meilleur
    leReseau = copier(leBon)

    -- Sauf pour les connexions où il y a une chance que le nul lui donne ses gènes
    for i = 1, #leReseau.lesConnexions do
        for j = 1, #leNul.lesConnexions do
            -- Si deux connexions partagent la même innovation et que le nul est actif,
            -- il y a une chance que la connexion du nul vienne remplacer celle du bon
            local memeInnovation = leReseau.lesConnexions[i].innovation == leNul.lesConnexions[j].innovation
            local nulActif = leNul.lesConnexions[j].actif

            if memeInnovation and nulActif then
                if math.random() > 0.5 then
                    leReseau.lesConnexions[i] = leNul.lesConnexions[j]
                end
            end
        end
    end

    -- Réinitialisation de la valeur fitness du nouveau réseau
    leReseau.fitness = 1
    return leReseau
end









function getNomFichierSauvegarde()
	local str = NOM_FICHIER_POPULATION 
	str = string.gsub(str, "IDGeneration", nbGeneration)
	return str
end

-- sauvegarde la population actuelle dans le fichier getNomFichierSauvegarde()
-- le dernier argument est reservé si le script detect que la population a terminée le niveau
function sauvegarderPopulation(laPopulation, estFini)
	chemin = getNomFichierSauvegarde()
	if estFini then
		chemin = "FINI " .. chemin
	end

	local fichier = io.open(chemin, "w+")
	io.output(fichier)

	-- sauvegarde classique de la population
	io.write(nbGeneration .. "\n")
	io.write(nbInnovation .. "\n")
	for i = 1, #laPopulation, 1 do
		sauvegarderUnReseau(laPopulation[i], fichier)
	end

	-- et là je sauvegarde le plus fort, c'est important pour pas perdre les progrés
	local lePlusFort = newReseau()
	for i = 1, #laPopulation, 1 do
		if lePlusFort.fitness < laPopulation[i].fitness then
			lePlusFort = copier(laPopulation[i])
		end
	end
	-- check aussi dans l'ancienne population (si plus fort, il ne peut etre que là)
	if #lesAnciennesPopulation > 0 then
		for i = 1, #lesAnciennesPopulation, 1 do
			for j = 1, #lesAnciennesPopulation[i], 1 do
				if lePlusFort.fitness < lesAnciennesPopulation[i][j].fitness then
					lePlusFort = copier(lesAnciennesPopulation[i][j])
				end
			end
		end
	end
	sauvegarderUnReseau(lePlusFort, fichier)
	io.close(fichier)

	console.log("sauvegarde terminee au fichier " .. chemin)
end

-- charge la population sauvegardé
-- renvoie la nouvelle population ou nil si le chemin n'est pas celui d'un fichier pop
function chargerPopulation(chemin)
	-- petit test pour voir si le fichier est ok
	local test = string.find(chemin, ".pop")
	local laPopulation = nil
	if test == nil then
		console.log("le fichier " .. chemin .. " n'est pas du bon format (.pop) je vais te monter en l'air ")
	else 
		laPopulation = {}
		local fichier = io.open(chemin, "r")
	
		io.input(fichier)

		local totalNeurone = 0
		local totalConnexion = 0

		nbGeneration = io.read("*number") 
		nbInnovation = io.read("*number")
		for i = 1, NB_INDIVIDU_POPULATION, 1 do
			table.insert(laPopulation, chargerUnReseau(fichier))
			laPopulation[i].fitness = 1
		end
	
		lesAnciennesPopulation = {} -- obligé !
		-- en mettant le plus fort ici, i lsera forcement lu dans nouvelleGeneration
		table.insert(lesAnciennesPopulation, copier(laPopulation))
		lesAnciennesPopulation[1][1] = chargerUnReseau(fichier)

		console.log("plus fort charge")
		console.log(lesAnciennesPopulation[1][1])
		-- si le plus fort a fini le niveau, tous les individus de la population deviennent le plus fort
		if lesAnciennesPopulation[1][1].fitness == FITNESS_LEVEL_FINI then
			for i = 1, NB_INDIVIDU_POPULATION, 1 do
				laPopulation[i] = copier(lesAnciennesPopulation[1][1])
			end
		end
		io.close(fichier)
		console.log("chargement termine de " .. chemin)
	end

	return laPopulation
end

-- sauvegarde un seul reseau
function sauvegarderUnReseau(unReseau, fichier)
	io.write(unReseau.nbNeurone .. "\n")
	io.write(#unReseau.lesConnexions .. "\n")
	io.write(unReseau.fitness .. "\n")
	for i = 1, unReseau.nbNeurone, 1 do
		local indice = NB_INPUT + NB_OUTPUT + i
		-- pas besoin d'écrire le type, je ne sauvegarde que les hiddens
		-- *non plus la valeur, car c'est reset toutes les frames en fait
		io.write(unReseau.lesNeurones[indice].id .. "\n")
	end
	for i = 1, #unReseau.lesConnexions, 1 do
		-- obligé car actif est un bool
		local actif = 1 
		if unReseau.lesConnexions[i].actif ~= true then
			actif = 0
		end
		io.write(actif .. "\n" .. 
			unReseau.lesConnexions[i].entree .. "\n" ..
			unReseau.lesConnexions[i].sortie .. "\n" .. 
			unReseau.lesConnexions[i].poids .. "\n" .. 
			unReseau.lesConnexions[i].innovation .. "\n")
	end
end


-- charge un seul reseau
function chargerUnReseau(fichier)
	local unReseau = newReseau()
	local nbNeurone = io.read("*number")
	local nbConnexion = io.read("*number")
	unReseau.fitness = io.read("*number")
	unReseau.nbNeurone = nbNeurone
	unReseau.lesConnexions = {}
	for i = 1, nbNeurone, 1 do
		local neurone = newNeurone()
		neurone.id = io.read("*number")
		neurone.valeur = 0
		neurone.type = "hidden"
		
		table.insert(unReseau.lesNeurones, neurone)
	end
		
	for i = 1, nbConnexion, 1 do
		local connexion = newConnexion()

		local actif = io.read("*number")
		connexion.entree = io.read("*number")
		connexion.sortie = io.read("*number")
		connexion.poids = io.read("*number")
		connexion.innovation = io.read("*number")

		if actif == 1 then
			connexion.actif = true
		else
			connexion.actif = false
		end
			
		table.insert(unReseau.lesConnexions, connexion)
	end

	return unReseau
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


-- renvoie l'indice du tableau lesInputs avec les coordonnées x y, peut être utilisé aussi pour acceder aux inputs du réseau de neurone
function getIndiceLesInputs(x, y)
	return x + ((y-1) * NB_TILE_W)
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



-- retourne une liste de taille 10 max de la position (x, y) des sprites à l'écran. (sprite = mechant truc)
function getLesSprites()
	local lesSprites = {}
	local j = 1
	for i = 0, NB_SPRITE_MAX, 1 do
		-- si 14C8+i est > 7 il est dans un etat considéré vivant, et si 0x167A == 0 c'est qu'il fait des dégats à Mario
		if memory.readbyte(0x14C8+i) > 7 then  
			-- le sprite existe 
			lesSprites[j] = {x = memory.readbyte(0xE4+i) + memory.readbyte(0x14E0+i) * 256, 
							 y = math.floor(memory.readbyte(0xD8+i) + memory.readbyte(0x14D4+i) * 256)}
			j = j + 1
		end
	end
	

	-- ça c'est les extended sprites, c'est d'autres truc du jeu en gros
	for i = 0, NB_SPRITE_MAX, 1 do
		if memory.readbyte(0x170B+i) ~= 0 then
			lesSprites[j] = {x = memory.readbyte(0x171F+i) + memory.readbyte(0x1733+i) * 256, 
							 y = math.floor(memory.readbyte(0x1715+i) + memory.readbyte(0x1729+i) * 256)}
			j = j + 1
		end
	end

	return lesSprites
end




-- renvoie une table qui a la meme taille que lesInputs. On y accède de la meme façon
function getLesTiles()
	local lesTiles = {}
	local j = 1


	-- les tiles vont etre affiché autour de mario
	mario = getPositionMario()
	mario.x = mario.x - TAILLE_VUE_W / 2
	mario.y = mario.y - TAILLE_VUE_H / 2

	for i = 1, NB_TILE_W, 1 do
		for j = 1, NB_TILE_H, 1 do
			 
			
			local xT = math.ceil((mario.x + ((i - 1) * TAILLE_TILE)) / TAILLE_TILE) 
			local yT = math.ceil((mario.y + ((j - 1) * TAILLE_TILE)) / TAILLE_TILE)

			if xT > 0 and yT > 0 then 
				-- plus d'info ici pour l'adresse memoire des blocs https://www.smwcentral.net/?p=section&a=details&id=21702
				lesTiles[getIndiceLesInputs(i, j)] = memory.readbyte(
					0x1C800 + 
					math.floor(xT / TAILLE_TILE) * 
					0x1B0 + 
					yT * TAILLE_TILE + 
					xT % TAILLE_TILE)
			else
				lesTiles[getIndiceLesInputs(i, j)] = 0
			end
		end
	end
	
	return lesTiles
end




-- retourne la position de mario (x, y)
function getPositionMario()
	local mario = {} 
	mario.x = memory.read_s16_le(0x94) 
	mario.y = memory.read_s16_le(0x96)
	return mario
end




-- retourne la position de la camera (x, y)
function getPositionCamera()
	local camera = {} 
	camera.x = memory.read_s16_le(0x1462) 
	camera.y = memory.read_s16_le(0x1464)
	
	return camera
end



-- permet de convertir une position pour avoir les arguments x et y du tableau lesInputs
function convertirPositionPourInput(position)
	local mario = getPositionMario()
	local positionT = {}
	mario.x = mario.x - TAILLE_VUE_W / 2
	mario.y = mario.y - TAILLE_VUE_H / 2

	positionT.x = math.floor((position.x - mario.x) / TAILLE_TILE) + 1
	positionT.y = math.floor((position.y - mario.y) / TAILLE_TILE) + 1

	return positionT
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


function traitementPause()
	local lesBoutons = joypad.get(1)
	if lesBoutons["P1 Start"] then
		lesBoutons["P1 Start"] = false
	else
		lesBoutons["P1 Start"] = true
	end
	joypad.set(lesBoutons)
end

function resetFitnessMax()
    fitnessMax = 0
end



-- dessine les informations actuelles
function dessinerLesInfos(laPopulation, lesEspeces, nbGeneration)
	gui.drawBox(0, 0, 256, 40, "black", "white")

	gui.drawText(0, 4, "Generation " .. nbGeneration .. " Ind:" .. idPopulation .. " nb espece " .. 
							#lesEspeces .. "\nFitness:" .. 
							laPopulation[idPopulation].fitness .. " (max = " .. fitnessMax .. ")", "black")
end




function dessinerUnReseau(unReseau)
	-- je commence par les inputs
	local lesInputs = getLesInputs()
	local camera = getPositionCamera()
	local lesPositions = {} -- va retenir toutes les positions des neurones affichées, ça sera plus facile pour les connexions
	
	for i = 1, NB_TILE_W, 1 do
		for j = 1, NB_TILE_H, 1 do
			local indice = getIndiceLesInputs(i, j)

			-- le i - 1 et j - 1 c'est juste pour afficher les cases à la position x, y quand ils sont == 0
			local xT = ENCRAGE_X_INPUT + (i - 1) * TAILLE_INPUT
			local yT = ENCRAGE_Y_INPUT + (j - 1) * TAILLE_INPUT
			
			
			local couleurFond = "gray"
			if unReseau.lesNeurones[indice].valeur < 0 then
				couleurFond = "black"
			elseif unReseau.lesNeurones[indice].valeur > 0 then
				couleurFond = "white"
			end
			
			gui.drawRectangle(xT, yT, TAILLE_INPUT, TAILLE_INPUT, "black", couleurFond)

			lesPositions[indice] = {}
			lesPositions[indice].x = xT + TAILLE_INPUT / 2
			lesPositions[indice].y = yT + TAILLE_INPUT / 2
		end
	end



	-- affichage du MARIO sur la grille, MARIO N'EST PAS UNE INPUT OUI C'EST POUR FAIRE JOLIE
	local mario = convertirPositionPourInput(getPositionMario())

	-- je respecte la meme regle qu'au dessus
	mario.x = (mario.x - 1) * TAILLE_INPUT + ENCRAGE_X_INPUT
	mario.y = (mario.y - 1) * TAILLE_INPUT + ENCRAGE_Y_INPUT
	-- mario est 2 fois plus grand que les autres sprites, car sa position est celle qu'il a quand il est grand
	gui.drawRectangle(mario.x, mario.y, TAILLE_INPUT, TAILLE_INPUT * 2, "black", "blue")

	for i = 1, NB_OUTPUT, 1 do
		local xT = ENCRAGE_X_OUTPUT
		local yT = ENCRAGE_Y_OUTPUT + ESPACE_Y_OUTPUT * (i - 1)
		local nomT = string.sub(lesBoutons[i].nom, 4)
		local indice = i + NB_INPUT

		if sigmoid(unReseau.lesNeurones[indice].valeur) then
			gui.drawRectangle(xT, yT, TAILLE_OUTPUT_W, TAILLE_OUTPUT_H, "white", "white")
		else
			gui.drawRectangle(xT, yT, TAILLE_OUTPUT_W, TAILLE_OUTPUT_H, "white", "black")
		end
		
		xT = xT + TAILLE_OUTPUT_W
		local strValeur = string.format("%.2f", unReseau.lesNeurones[indice].valeur)
		--c'est pour afficher la valeur de l'input stv
		gui.drawText(xT, yT-1, nomT -- .. "(" .. strValeur .. ")" -- 
						, "white", "black", 10)
		lesPositions[indice] = {}
		lesPositions[indice].x = xT - TAILLE_OUTPUT_W / 2
		lesPositions[indice].y = yT + TAILLE_OUTPUT_H / 2
	end

	for i = 1, unReseau.nbNeurone, 1 do
		local xT = ENCRAGE_X_HIDDEN + (TAILLE_HIDDEN + 1) * (i - (NB_HIDDEN_PAR_LIGNE * math.floor((i-1) / NB_HIDDEN_PAR_LIGNE)))
		local yT = ENCRAGE_Y_HIDDEN + (TAILLE_HIDDEN + 1) * (math.floor((i-1) / NB_HIDDEN_PAR_LIGNE))
		-- tous les 10 j'affiche le restant des neuroens en dessous

		local indice = i + NB_INPUT + NB_OUTPUT
		gui.drawRectangle(xT, yT, TAILLE_HIDDEN, TAILLE_HIDDEN, "black", "white")

		lesPositions[indice] = {}
		lesPositions[indice].x = xT + TAILLE_HIDDEN / 2
		lesPositions[indice].y = yT + TAILLE_HIDDEN / 2
	end




	-- affichage des connexions 
	for i = 1, #unReseau.lesConnexions, 1 do
		if unReseau.lesConnexions[i].actif then
			local pixel = 0
			local alpha = 255
			local couleur
			if unReseau.lesConnexions[i].poids > 0 then
				pixel = 255
			end

			if not unReseau.lesConnexions[i].allume then
				alpha = 25
			end

			couleur = forms.createcolor(pixel, pixel, pixel, alpha)

			gui.drawLine(lesPositions[unReseau.lesConnexions[i].entree].x, 
						  lesPositions[unReseau.lesConnexions[i].entree].y, 
						  lesPositions[unReseau.lesConnexions[i].sortie].x, 
						  lesPositions[unReseau.lesConnexions[i].sortie].y, 
						  couleur)
		end
	end
end




event.onexit(function()
	console.log("Fin du script")
	gui.clearGraphics()
	forms.destroy(form)
end)

-- pas le choix de passer comme ça pour activer la sauvegarde
function activerSauvegarde()
	sauvegarderPopulation(laPopulation, false)
end

-- pareil pour le chargement
function activerChargement()
	chemin = forms.openfile()
	-- possible que la fenetre soit fermée donc chemin nil
	if chemin ~= "" then 
		local laPopulationT = chargerPopulation(chemin)
		if laPopulationT ~= nil then
			laPopulation = {}
			laPopulation = copier(laPopulationT)
			idPopulation = 1
			lancerNiveau()
		end
	end
end

-- relance le niveau et reset tout pour le nouvel individu
function lancerNiveau()
	savestate.load(NOM_SAVESTATE)
	marioBase = getPositionMario()
	niveauFini = false
	nbFrameStop = 0
end

console.clear()
-- petit check pour voir si c'est bien la bonne rom
if gameinfo.getromname() ~= NOM_JEU then
	console.log("mauvaise rom (actuellement " .. gameinfo.getromname() .. "), marche uniquement avec " .. nomJeu)
else
	console.log("lancement du script")
	math.randomseed(os.time())
	
	lancerNiveau()

	form = forms.newform(TAILLE_FORM_W, TAILLE_FORM_H, "Informations")
	labelInfo = forms.label(form, "a maj", 0, 0, 350, 220)
	estAccelere = forms.checkbox(form, "Accelerer", 10, 220)
	estAfficheReseau = forms.checkbox(form, "Afficher reseau", 10, 240)
	estAfficheInfo = forms.checkbox(form, "Afficher bandeau", 10, 260)
	forms.button(form, "Pause", traitementPause, 10, 285)
	forms.button(form, "Sauvegarder", activerSauvegarde, 10, 315)
	forms.button(form, "Charger", activerChargement, 100, 315)
	forms.button(form, "Réinitialiser fitness max", resetFitnessMax, 100, 285)

	laPopulation = newPopulation() 
	
	for i = 1, #laPopulation, 1 do
		mutation(laPopulation[i])
	end	

	for i = 2, #laPopulation, 1 do
		laPopulation[i] = copier(laPopulation[1])
		mutation(laPopulation[i])
	end	

	lesEspeces = trierPopulation(laPopulation)
	laPopulation = nouvelleGeneration(laPopulation, lesEspeces)

	-- boucle principale 
	while true do
		
		-- ça va permettre de suivre si pendant cette frame il y a du l'evolution
		local fitnessAvant = laPopulation[idPopulation].fitness
		nettoyer = true


		if forms.ischecked(estAccelere) then
			emu.limitframerate(false)
		else
			emu.limitframerate(true)
		end

		if forms.ischecked(estAfficheReseau) then
			dessinerUnReseau(laPopulation[idPopulation])
			nettoyer = false
		end

		if forms.ischecked(estAfficheInfo) then
			dessinerLesInfos(laPopulation, lesEspeces, nbGeneration)
			nettoyer = false
		end



		if nettoyer then
			gui.clearGraphics()
		end


		majReseau(laPopulation[idPopulation], marioBase)
		feedForward(laPopulation[idPopulation])
		appliquerLesBoutons(laPopulation[idPopulation])

		
		if nbFrame == 0 then
			fitnessInit = laPopulation[idPopulation].fitness
		end

		emu.frameadvance()
		nbFrame = nbFrame + 1


		if fitnessMax < laPopulation[idPopulation].fitness then
			fitnessMax = laPopulation[idPopulation].fitness
		end

		-- si pas d'évolution ET que le jeu n'est pas en pause, on va voir si on reset ou pas
		if fitnessAvant == laPopulation[idPopulation].fitness and memory.readbyte(0x13D4) == 0 then
			nbFrameStop = nbFrameStop + 1
			local nbFrameReset = NB_FRAME_RESET_BASE
			-- si il y a eu progrés ET QUE mario n'est pas MORT
			if fitnessInit ~= laPopulation[idPopulation].fitness and memory.readbyte(0x0071) ~= 9 then
				nbFrameReset = NB_FRAME_RESET_PROGRES
			end
			if nbFrameStop > nbFrameReset then
				nbFrameStop = 0
				lancerNiveau()
				idPopulation = idPopulation + 1
				-- si on en est là, on va refaire une generation
				if idPopulation > #laPopulation then
					-- je check avant tout si le niveau a pas été terminé 
					if not niveauFiniSauvegarde then
						for i = 1, #laPopulation, 1 do
							-- le level a été fini une fois, 
							if laPopulation[i].fitness == FITNESS_LEVEL_FINI then
								sauvegarderPopulation(laPopulation, true)
								niveauFiniSauvegarde = true
								console.log("Niveau fini apres " .. nbGeneration .. " generation !")
							end
						end
					end
					idPopulation = 1
					nbGeneration = nbGeneration + 1
					lesEspeces = trierPopulation(laPopulation)
					laPopulation = nouvelleGeneration(laPopulation, lesEspeces)
					nbFrame = 0
					fitnessInit = 0
				end
			end
		else
			nbFrameStop = 0
		end

		-- maj du label actuel
		local str = "generation " .. nbGeneration .. " Fitness maximal: " .. 
						fitnessMax .. "\nInformations sur l'individu actuel:\n" .. 
						"id: " .. idPopulation .. "/" .. #laPopulation .." neurones: " .. 
						#laPopulation[idPopulation].lesNeurones .. " connexions: " ..
						#laPopulation[idPopulation].lesConnexions .. " enfant de l'espece " .. 
						laPopulation[idPopulation].idEspeceParent ..
						"\n\nInfos sur les especes: " .. 
						"\nIl y a " .. #lesEspeces .. " espece(s) "
		for i = 1, #lesEspeces, 1 do
			str = str .. "\nespece " .. i .. " a fait " .. lesEspeces[i].nbEnfant .. " enfant(s)"  .. " (fitnessmax " .. lesEspeces[i].fitnessMax .. ") "
		end
		forms.settext(labelInfo, str)
	end
	
end