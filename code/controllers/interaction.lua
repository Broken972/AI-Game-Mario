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



