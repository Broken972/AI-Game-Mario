
-- créé une connexion
function newConnexion()
	local connexion = {}
	connexion.entree = 0 
	connexion.sortie = 0
	connexion.actif = true
	connexion.poids = 0
	connexion.innovation = 0
	connexion.allume = false -- pour le dessin, si true ça veut dire que le resultat de la connexion est different de 0
	return connexion
end

-- créé un reseau de neurone 
function newReseau()
	local reseau = {nbNeurone = 0,  -- taille des neurones  rajouté par l'algo (hors input output du coup)
						fitness = 1, -- beaucoup de division, pour eviter de faire l irreparable
						idEspeceParent = 0,
						lesNeurones = {}, 
						lesConnexions = {}}
	for j = 1, NB_INPUT, 1 do 
		ajouterNeurone(reseau, j, "input", 1)
	end
 
 
	-- ensuite, les outputs
	for j = NB_INPUT + 1, NB_INPUT + NB_OUTPUT, 1 do
		ajouterNeurone(reseau, j, "output", 0)
	end
 
 
	return reseau
end

-- ajoute une connexion a un reseau de neurone
function ajouterConnexion(unReseau, entree, sortie, poids)
	-- test pour voir si tout va bien et que les neurones de la connexion existent bien
	if unReseau.lesNeurones[entree].id == 0 then
		console.log("connexion avec l'entree " .. entree .. " n'est pas init ?")
	elseif unReseau.lesNeurones[sortie].id == 0 then
		console.log("connexion avec la sortie " .. sortie .. " n'est pas init ?")
	else
		local connexion = newConnexion()
		connexion.actif = true
		connexion.entree = entree
		connexion.sortie = sortie
		connexion.poids = genererPoids()
		connexion.innovation = nbInnovation
		table.insert(unReseau.lesConnexions, connexion)
		nbInnovation = nbInnovation + 1
	end
end


-- retourne la difference de poids de 2 réseaux de neurones (uniquement des memes innovations)
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
 
	-- si aucune connexion en commun c'est qu'ils sont trop differents
	-- puis si on laisse comme ça on va diviser par 0 et on va lancer mario maker
	if nbConnexion == 0 then
		return 100000
	end
 
 
	return total / nbConnexion
end


-- retourne le nombre de connexion qui n'ont aucun rapport entre les 2 reseaux
function getDisjoint(unReseau1, unReseau2)
	local nbPareil = 0
	for i = 1, #unReseau1.lesConnexions, 1 do
		for j = 1, #unReseau2.lesConnexions, 1 do
			if unReseau1.lesConnexions[i].innovation == unReseau2.lesConnexions[j].innovation then
				nbPareil = nbPareil + 1
			end
		end
	end
 
	-- oui ça marche
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
 
 
 
 
-- retourne un melange des 2 reseaux de neurones
function crossover(unReseau1, unReseau2)
	local leReseau = newReseau()
 
 
	-- quel est le meilleur des deux ?
	local leBon = newReseau()
	local leNul = newReseau()
 
 
	leBon = unReseau1
	leNul = unReseau2
	if leBon.fitness < leNul.fitness then
		leBon = unReseau2
		leNul = unReseau1
	end
 
	-- le nouveau reseau va hériter de la majorité des attributs du meilleur
	leReseau = copier(leBon)
 
	-- sauf pour les connexions où y a une chance que le nul lui donne ses genes
	for i = 1, #leReseau.lesConnexions, 1 do
		for j = 1, #leNul.lesConnexions, 1 do
			-- si 2 connexions partagent la meme innovation, la connexion du nul peut venir la remplacer 
			-- *seulement si nul est actif, sans ça ça créé des neurones hiddens inutiles*
			if leReseau.lesConnexions[i].innovation == leNul.lesConnexions[j].innovation and leNul.lesConnexions[j].actif then
				if math.random() > 0.5 then
					leReseau.lesConnexions[i] = leNul.lesConnexions[j]
				end
			end
		end
	end
	leReseau.fitness = 1
	return leReseau
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