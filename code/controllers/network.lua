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
