
-- créé une population
function newPopulation() 
	local population = {}
	for i = 1, NB_INDIVIDU_POPULATION, 1 do
		table.insert(population, newReseau())
	end
	return population
end

-- place la population et la renvoie divisée dans une tableau 2D
function trierPopulation(laPopulation)
	local lesEspeces = {}
	table.insert(lesEspeces, newEspece())
 
	-- la premiere espece créée et le dernier element de la premiere population
	-- comme ça, j'ai déjà une première espèce créée
	table.insert(lesEspeces[1].lesReseaux, copier(laPopulation[#laPopulation]))
 
	for i = 1, #laPopulation-1, 1 do
		local trouve = false
		for j = 1, #lesEspeces, 1 do
			local indice = math.random(1, #lesEspeces[j].lesReseaux)
			local rep = lesEspeces[j].lesReseaux[indice]
			-- il peut être classé 
			if getScore(laPopulation[i], rep) < DIFF_LIMITE then
				table.insert(lesEspeces[j].lesReseaux, copier(laPopulation[i]))
				trouve = true
				break
			end
		end
 
		-- si pas trouvé, il faut créer une especes pour l'individu
		if trouve == false then
			table.insert(lesEspeces, newEspece())
			table.insert(lesEspeces[#lesEspeces].lesReseaux, copier(laPopulation[i]))
		end
	end
 
	return lesEspeces
end


-- renvoie une copie d'un parent choisis dans une espece
function choisirParent(uneEspece)
	if #uneEspece == 0 then
		console.log("uneEspece vide dans choisir parent ??")
	end
	-- il est possible que l'espece ne contienne qu'un seul reseau, dans ce cas là on va pas plus loin
	if #uneEspece == 1 then
		return uneEspece[1]
	end
 
	local fitnessTotal = 0
	for i = 1, #uneEspece, 1 do
		fitnessTotal = fitnessTotal + uneEspece[i].fitness
	end
	local limite = math.random(0, fitnessTotal)
	local total = 0
	for i = 1, #uneEspece, 1 do
		total = total + uneEspece[i].fitness
		-- si la somme des fitness cumulés depasse total, on renvoie l'espece qui a fait depasser la limite
		if total >= limite then
			return copier(uneEspece[i])
		end
	end
	console.log("impossible de trouver un parent ?")
	return nil
end
 
 
-- créé une nouvelle generation, renvoie la population créée
-- il faut que les especes soit triée avant appel
function nouvelleGeneration(laPopulation, lesEspeces)
	local laNouvellePopulation = newPopulation()
	-- nombre d'indivu à creer au total
	local nbIndividuACreer = NB_INDIVIDU_POPULATION
	 -- indice qui va servir à savoir OU en est le tab de la nouvelle espece
	local indiceNouvelleEspece = 1
 
	-- il est possible que l'ancien meilleur ait un meilleur fitness
	-- que celui de la nouvelle population (une mauvaise mutation ça arrive très souvent)
	-- dans ce cas je le supprime par l'ancien meilleur histoire d'être SUR d'avoir des enfants
	-- toujours du plus bon
	local fitnessMaxPop = 0
	local fitnessMaxAncPop = 0
	local ancienPlusFort = {}
	for i = 1, #laPopulation, 1 do
		if fitnessMaxPop < laPopulation[i].fitness then
			fitnessMaxPop = laPopulation[i].fitness
		end
	end
	-- on test que si il y a deja une ancienne population evidamment
	if #lesAnciennesPopulation > 0 then
		-- je vais checker TOUTES les anciennes population pour la fitness la plus élevée
		-- vu que les reseaux vont REmuter, il est possible qu'ils fassent moins bon !
		for i = 1, #lesAnciennesPopulation, 1 do
			for j = 1, #lesAnciennesPopulation[i], 1 do
				if fitnessMaxAncPop < lesAnciennesPopulation[i][j].fitness then
					fitnessMaxAncPop = lesAnciennesPopulation[i][j].fitness
					ancienPlusFort = lesAnciennesPopulation[i][j]
				end
			end
		end
	end
 
	if fitnessMaxAncPop > fitnessMaxPop then
		-- comme ça je suis sur uqe le meilleur dominera totalement
		for i = 1, #lesEspeces, 1 do
			for j = 1, #lesEspeces[i].lesReseaux, 1 do
				lesEspeces[i].lesReseaux[j] = copier(ancienPlusFort)
			end
		end
		console.log("mauvaise population je reprends la meilleur et ça redevient la base de la nouvelle pop")
		console.log(ancienPlusFort)
	end
 
	table.insert(lesAnciennesPopulation, laPopulation)
 
	-- calcul fitness pour chaque espece
	local nbIndividuTotal = 0
	local fitnessMoyenneGlobal = 0 -- fitness moyenne de TOUS les individus de toutes les especes
	local leMeilleur = newReseau() -- je dois le remettre avant tout, on va essayer de trouver ou i lest
	for i = 1, #lesEspeces, 1 do
		lesEspeces[i].fitnessMoyenne = 0
		lesEspeces[i].lesReseaux.fitnessMax = 0
		for j = 1, #lesEspeces[i].lesReseaux, 1 do
			lesEspeces[i].fitnessMoyenne = lesEspeces[i].fitnessMoyenne + lesEspeces[i].lesReseaux[j].fitness
			fitnessMoyenneGlobal = fitnessMoyenneGlobal + lesEspeces[i].lesReseaux[j].fitness
			nbIndividuTotal = nbIndividuTotal + 1
 
			if lesEspeces[i].fitnessMax < lesEspeces[i].lesReseaux[j].fitness then
				lesEspeces[i].fitnessMax = lesEspeces[i].lesReseaux[j].fitness
				if leMeilleur.fitness < lesEspeces[i].lesReseaux[j].fitness then
					leMeilleur = copier(lesEspeces[i].lesReseaux[j])
				end
			end
		end
		lesEspeces[i].fitnessMoyenne = lesEspeces[i].fitnessMoyenne / #lesEspeces[i].lesReseaux
	end
 
	-- si le level a été terminé au moins une fois, tous les individus deviennent le meilleur, on ne recherche plus de mutation là
	if leMeilleur.fitness == FITNESS_LEVEL_FINI then
		for i = 1, #lesEspeces, 1 do
			for j = 1, #lesEspeces[i].lesReseaux, 1 do
				lesEspeces[i].lesReseaux[j] = copier(leMeilleur)
			end
		end
		fitnessMoyenneGlobal = leMeilleur.fitness
	else
		fitnessMoyenneGlobal = fitnessMoyenneGlobal / nbIndividuTotal
	end
 
	--tri des especes pour que les meilleurs place leurs enfants avant tout
	table.sort(lesEspeces, function (e1, e2) return e1.fitnessMax > e2.fitnessMax end )
 
	-- chaque espece va créer un certain nombre d'individu dans la nouvelle population en fonction de si l'espece a un bon fitness ou pas
	for i = 1, #lesEspeces, 1 do
		local nbIndividuEspece = math.ceil(#lesEspeces[i].lesReseaux * lesEspeces[i].fitnessMoyenne / fitnessMoyenneGlobal)
		nbIndividuACreer = nbIndividuACreer - nbIndividuEspece
		if nbIndividuACreer < 0 then
			nbIndividuEspece = nbIndividuEspece + nbIndividuACreer
			nbIndividuACreer = 0
		end
		lesEspeces[i].nbEnfant = nbIndividuEspece
 
 
		for j = 1, nbIndividuEspece, 1 do
			if indiceNouvelleEspece > NB_INDIVIDU_POPULATION then
				break
			end
 
			local unReseau = crossover(choisirParent(lesEspeces[i].lesReseaux), choisirParent(lesEspeces[i].lesReseaux))
 
			-- on stop la mutation à ce stade
			if fitnessMoyenneGlobal ~= FITNESS_LEVEL_FINI then
				mutation(unReseau)
			end
 
			unReseau.idEspeceParent = i
			laNouvellePopulation[indiceNouvelleEspece] = copier(unReseau)
			laNouvellePopulation[indiceNouvelleEspece].fitness = 1
			indiceNouvelleEspece = indiceNouvelleEspece + 1
		end
		if indiceNouvelleEspece > NB_INDIVIDU_POPULATION then
			break
		end
	end
 
	-- si une espece n'a pas fait d'enfant, je la delete
	for i = 1, #lesEspeces, 1 do
		if lesEspeces[i].nbEnfant == 0 then
			lesEspeces[i] = nil
		end
	end
 
	return laNouvellePopulation
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