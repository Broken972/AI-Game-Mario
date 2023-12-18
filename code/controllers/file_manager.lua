-- Définition de la fonction getNomFichierSauvegarde()
function getNomFichierSauvegarde()
    -- Déclaration d'une variable locale "str" pour stocker le nom de fichier
    local str = NOM_FICHIER_POPULATION

    -- Utilisation de la fonction string.gsub() pour remplacer "IDGeneration" par la valeur de "nbGeneration" dans la variable "str"
    -- Note : La valeur de "nbGeneration" doit être définie ailleurs dans le code pour que cela fonctionne correctement
    str = string.gsub(str, "IDGeneration", nbGeneration)

    -- Retourne la chaîne modifiée "str" qui est maintenant le nom de fichier final
    return str
end


function sauvegarderPopulation(laPopulation, estFini)
    local chemin = getNomFichierSauvegarde()
    if estFini then
        chemin = "Fini" .. chemin
    end

    local fichier = io.open(chemin, "w+")
    io.output(fichier)

    io.write(nbGeneration .. "\n")
    io.write(nbInnovation .. "\n")
    for i = 1, #laPopulation do
        sauvegarderUnReseau(laPopulation[i], fichier)
    end

    local lePlusFort = newReseau()
    for i = 1, #laPopulation do
        if lePlusFort.fitness < laPopulation[i].fitness then
            lePlusFort = copier(laPopulation[i])
        end
    end

    if #lesAnciennesPopulation > 0 then
        for i = 1, #lesAnciennesPopulation do
            for j = 1, #lesAnciennesPopulation[i] do
                if lePlusFort.fitness < lesAnciennesPopulation[i][j].fitness then
                    lePlusFort = copier(lesAnciennesPopulation[i][j])
                end
            end
        end
    end

    sauvegarderUnReseau(lePlusFort, fichier)

    -- Nouvelle logique pour sauvegarder et réinitialiser le réseau qui a fini le niveau
    if estFini then
        for _, reseau in ipairs(laPopulation) do
            if reseau.fitness == FITNESS_LEVEL_FINI then
                reseau.fitness = 0 -- Réinitialisation du fitness
                sauvegarderUnReseau(reseau, fichier)
                break
            end
        end
    end

    io.close(fichier)
    console.log("sauvegarde terminee au fichier " .. chemin)
end


function chargerPopulation(chemin)
    -- Effectue un test pour vérifier si le chemin du fichier se termine par ".pop"
    local test = string.find(chemin, ".pop")
    local laPopulation = nil

    -- Si le chemin du fichier n'a pas l'extension ".pop", affiche un message d'erreur
    if test == nil then
        console.log("le fichier " .. chemin .. " n'est pas du bon format (.pop) je vais te monter en l'air ")
    else
        -- Si le fichier est du bon format, initialise une table vide pour stocker la population
        laPopulation = {}

        -- Ouvre le fichier en mode lecture ("r")
        local fichier = io.open(chemin, "r")
        io.input(fichier)

        local totalNeurone = 0
        local totalConnexion = 0

        -- Lit les valeurs de nbGeneration et nbInnovation depuis le fichier
        nbGeneration = io.read("*number")
        nbInnovation = io.read("*number")

        -- Boucle pour charger chaque individu de la population
        for i = 1, NB_INDIVIDU_POPULATION, 1 do
            table.insert(laPopulation, chargerUnReseau(fichier))
            laPopulation[i].fitness = 1
        end

        -- Initialise une table vide pour les anciennes populations
        lesAnciennesPopulation = {}

        -- Insère la population actuelle (tous les individus) dans les anciennes populations
        table.insert(lesAnciennesPopulation, copier(laPopulation))
        lesAnciennesPopulation[1][1] = chargerUnReseau(fichier)

        console.log("plus fort charge")
        console.log(lesAnciennesPopulation[1][1])

        -- Si l'individu le plus fort a terminé le niveau, tous les individus de la population deviennent le plus fort
        if lesAnciennesPopulation[1][1].fitness == FITNESS_LEVEL_FINI then
            for i = 1, NB_INDIVIDU_POPULATION, 1 do
                laPopulation[i] = copier(lesAnciennesPopulation[1][1])
            end
        end

        -- Ferme le fichier
        io.close(fichier)
        console.log("chargement termine de " .. chemin)
    end

    return laPopulation
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

-- pas le choix de passer comme ça pour activer la sauvegarde
function activerSauvegarde()
	sauvegarderPopulation(laPopulation, false)
end

-- pareil pour le chargement
function activerChargement()
    -- Utilise "forms.openfile()" pour ouvrir une fenêtre de sélection de fichier et obtenir le chemin du fichier sélectionné
    chemin = forms.openfile()

    -- Vérifie si le chemin n'est pas une chaîne vide (signifie que l'utilisateur a sélectionné un fichier)
    if chemin ~= "" then
        -- Appelle la fonction "chargerPopulation" pour charger la population à partir du fichier
        local laPopulationT = chargerPopulation(chemin)

        -- Vérifie si la population a été chargée avec succès (non nulle)
        if laPopulationT ~= nil then
            -- Copie la population chargée dans la variable "laPopulation"
            laPopulation = {}
            laPopulation = copier(laPopulationT)

            -- Réinitialise la variable "idPopulation" à 1
            idPopulation = 1

            -- Lance le niveau avec la population chargée
            lancerNiveau()
        end
    end
end
