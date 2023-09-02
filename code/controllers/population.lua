-- Crée une nouvelle population avec NB_INDIVIDU_POPULATION réseaux de neurones
function newPopulation()
    local population = {}
    
    -- Remplit la population avec de nouveaux réseaux de neurones
    for i = 1, NB_INDIVIDU_POPULATION, 1 do
        table.insert(population, newReseau())
    end
    
    return population
end

-- Trie la population et la renvoie divisée dans un tableau 2D
function trierPopulation(laPopulation)
    local lesEspeces = {}
    table.insert(lesEspeces, newEspece())

    -- La première espèce créée est le dernier élément de la première population
    -- Ainsi, on a déjà une première espèce créée
    table.insert(lesEspeces[1].lesReseaux, copier(laPopulation[#laPopulation]))

    for i = 1, #laPopulation - 1, 1 do
        local trouve = false
        for j = 1, #lesEspeces, 1 do
            local indice = math.random(1, #lesEspeces[j].lesReseaux)
            local rep = lesEspeces[j].lesReseaux[indice]
            
            -- L'individu peut être classé
            if getScore(laPopulation[i], rep) < DIFF_LIMITE then
                table.insert(lesEspeces[j].lesReseaux, copier(laPopulation[i]))
                trouve = true
                break
            end
        end

        -- Si l'individu n'a pas été trouvé, il faut créer une espèce pour cet individu
        if trouve == false then
            table.insert(lesEspeces, newEspece())
            table.insert(lesEspeces[#lesEspeces].lesReseaux, copier(laPopulation[i]))
        end
    end

    return lesEspeces
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

-- Fonction pour choisir un parent dans une espèce en fonction de sa fitness
function choisirParent(uneEspece)
    -- Vérification si l'espèce est vide
    if #uneEspece == 0 then
        print("Erreur : uneEspece vide dans choisirParent")
        return nil
    end

    -- Si l'espèce ne contient qu'un seul réseau, on le retourne directement
    if #uneEspece == 1 then
        return uneEspece[1]
    end

    -- Calcul du total des fitness pour tous les réseaux de l'espèce
    local fitnessTotal = 0
    for i = 1, #uneEspece do
        fitnessTotal = fitnessTotal + uneEspece[i].fitness
    end

    -- Sélection d'un parent en fonction de la proportion de sa fitness par rapport au total
    local limite = math.random(0, fitnessTotal)
    local total = 0
    for i = 1, #uneEspece do
        total = total + uneEspece[i].fitness

        -- Si la somme des fitness cumulés dépasse la limite, on retourne le réseau qui a fait dépasser la limite
        if total >= limite then
            return copier(uneEspece[i])
        end
    end

    print("Erreur : impossible de trouver un parent")
    return nil
end
