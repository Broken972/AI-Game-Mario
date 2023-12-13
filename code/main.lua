-- Chargement des modules
local connection = require("./controllers/connection")
local constante = require("./controllers/constante")
local display = require("./controllers/display")
local event_handlers = require("./controllers/event_handlers")
local game_logic = require("./controllers/game_logic")
local interaction = require("./controllers/interaction")
local network_manager = require("./controllers/network_manager")
local network = require("./controllers/network")
local neuron = require("./controllers/neuron")
local panel = require("./controllers/panel")
local population = require("./controllers/population")
local species = require("./controllers/species")
local ui_manager = require("./controllers/ui_manager")
local utils = require("./controllers/utils")

-- Gère la fermeture du script
event.onexit(function()
	console.log("Fin du script")  -- Affiche un message lors de la fin du script
	gui.clearGraphics()  -- Nettoie les graphiques de l'interface utilisateur
	forms.destroy(form)  -- Détruit le formulaire (fenêtre)
end)

event.onexit(terminerScript)  -- Appel d'une fonction de nettoyage supplémentaire lors de la fermeture

console.clear()  -- Nettoie la console

-- Vérifie si la ROM du jeu est correcte
if gameinfo.getromname() ~= NOM_JEU then
	console.log("mauvaise rom (actuellement " .. gameinfo.getromname() .. "), marche uniquement avec " .. nomJeu)
else
	console.log("lancement du script")
	math.randomseed(os.time())  -- Initialise le générateur de nombres aléatoires
	
	lancerNiveau()  -- Démarre un niveau du jeu

	form = forms.newform(TAILLE_FORM_W, TAILLE_FORM_H, "Informations")  -- Crée une nouvelle fenêtre/formulaire
	
	initializeUI()  -- Initialise l'interface utilisateur

	laPopulation = newPopulation()  -- Crée une nouvelle population
	
	for i = 1, #laPopulation, 1 do
		mutation(laPopulation[i])  -- Applique des mutations aux individus de la population
	end	

	for i = 2, #laPopulation, 1 do
		laPopulation[i] = copier(laPopulation[1])  -- Copie et applique des mutations aux individus
		mutation(laPopulation[i])
	end	

	lesEspeces = trierPopulation(laPopulation)  -- Trie la population en espèces
	laPopulation = nouvelleGeneration(laPopulation, lesEspeces)  -- Crée une nouvelle génération de la population

	-- Boucle principale
	while true do
		
		local fitnessAvant = laPopulation[idPopulation].fitness  -- Fitness de l'individu avant la mise à jour
		nettoyer = true  -- Indicateur pour nettoyer les graphiques

		-- Gestion de l'accélération du jeu et de l'affichage
		if forms.ischecked(estAccelere) then
			emu.limitframerate(false)
		else
			emu.limitframerate(true)
		end

		if forms.ischecked(estAfficheReseau) then
			dessinerUnReseau(laPopulation[idPopulation])  -- Dessine le réseau de neurones
			nettoyer = false
		end

		if forms.ischecked(estAfficheInfo) then
			dessinerLesInfos(laPopulation, lesEspeces, nbGeneration)  -- Dessine les informations sur la population et les espèces
			nettoyer = false
		end

		if nettoyer then
			gui.clearGraphics()  -- Nettoie les graphiques si nécessaire
		end

		-- Mise à jour du réseau de neurones et application des commandes
		majReseau(laPopulation[idPopulation], marioBase)
		feedForward(laPopulation[idPopulation])
		appliquerLesBoutons(laPopulation[idPopulation])

		-- Gestion de la fitness et des générations
		if nbFrame == 0 then
			fitnessInit = laPopulation[idPopulation].fitness
		end

		emu.frameadvance()  -- Avance d'une frame dans l'émulateur
		nbFrame = nbFrame + 1

		if fitnessMax < laPopulation[idPopulation].fitness then
			fitnessMax = laPopulation[idPopulation].fitness  -- Mise à jour de la fitness maximale
		end

		-- Réinitialisation et gestion des générations
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
								break
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

		-- Mise à jour de l'affichage des informations
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
