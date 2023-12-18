function gererPopulation()
    laPopulation = newPopulation()
    for i = 1, #laPopulation do
        mutation(laPopulation[i])
    end

    for i = 2, #laPopulation do
        laPopulation[i] = copier(laPopulation[1])
        mutation(laPopulation[i])
    end

    lesEspeces = trierPopulation(laPopulation)
    laPopulation = nouvelleGeneration(laPopulation, lesEspeces)
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

-- Crée une nouvelle population avec NB_INDIVIDU_POPULATION réseaux de neurones
function newPopulation()
    local population = {}
    
    -- Remplit la population avec de nouveaux réseaux de neurones
    for i = 1, NB_INDIVIDU_POPULATION, 1 do
        table.insert(population, newReseau())
    end
    
    return population
end

-- Crée une nouvelle génération et renvoie la population créée
-- Les espèces doivent être triées avant l'appel de cette fonction
function nouvelleGeneration(laPopulation, lesEspeces)
    local laNouvellePopulation = newPopulation()
    -- Nombre d'individus à créer au total
    local nbIndividuACreer = NB_INDIVIDU_POPULATION
    -- Indice qui va servir à savoir où en est le tableau de la nouvelle espèce
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

	 -- Si le niveau a été terminé au moins une fois, tous les individus deviennent le meilleur,
    -- on ne recherche plus de mutation là
    if leMeilleur.fitness == FITNESS_LEVEL_FINI then
        for i = 1, #lesEspeces do
            for j = 1, #lesEspeces[i].lesReseaux do
                lesEspeces[i].lesReseaux[j] = copier(leMeilleur)
            end
        end
        fitnessMoyenneGlobal = leMeilleur.fitness
    else
        fitnessMoyenneGlobal = fitnessMoyenneGlobal / nbIndividuTotal
    end

	--tri des especes pour que les meilleurs place leurs enfants avant tout
	table.sort(lesEspeces, function (e1, e2) return e1.fitnessMax > e2.fitnessMax end )

	-- Chaque espèce va créer un certain nombre d'individus dans la nouvelle population
    -- en fonction de si l'espèce a un bon fitness ou pas
    for i = 1, #lesEspeces do
		local nbIndividuEspece = math.ceil(#lesEspeces[i].lesReseaux * lesEspeces[i].fitnessMoyenne / fitnessMoyenneGlobal)
		nbIndividuACreer = nbIndividuACreer - nbIndividuEspece
		if nbIndividuACreer < 0 then
			nbIndividuEspece = nbIndividuEspece + nbIndividuACreer
			nbIndividuACreer = 0
		end
		lesEspeces[i].nbEnfant = nbIndividuEspece


		for j = 1, nbIndividuEspece do
			if indiceNouvelleEspece > NB_INDIVIDU_POPULATION then
				break
			end

			local unReseau = crossover(choisirParent(lesEspeces[i].lesReseaux), choisirParent(lesEspeces[i].lesReseaux))
			
			-- On stoppe la mutation à ce stade
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
	
	-- Si une espèce n'a pas fait d'enfant, on la supprime
    for i = #lesEspeces, 1, -1 do
        if lesEspeces[i].nbEnfant == 0 then
            table.remove(lesEspeces, i)
        end
    end

	return laNouvellePopulation
end

