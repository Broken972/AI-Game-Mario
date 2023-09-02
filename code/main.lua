-- Loading constants module
dofile("./controllers/constante.lua")

-- Loading population module
dofile("./controllers/population.lua")

-- Loading neurone module
dofile("./controllers/neurone.lua")

-- Loading connexion module
dofile("./controllers/connexion.lua")

-- Loading reseau module
dofile("./controllers/reseau.lua")

-- Loading espece module
dofile("./controllers/espece.lua")

-- Loading utils module
dofile("./controllers/utils.lua")

-- Loading affichage module
dofile("./controllers/affichage.lua")

-- Loading panel module
dofile("./controllers/utils.lua")

































































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







event.onexit(function()
	console.log("Fin du script")
	gui.clearGraphics()
	forms.destroy(form)
end)


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