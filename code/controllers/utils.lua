function resetFitnessMax()
    fitnessMax = 0
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

-- fonction d'activation
function sigmoid(x)
	local resultat = x / (1 + math.abs(x))
	if resultat >= 0.5 then
		return true
	end
	return false
end

-- genere un poids aléatoire (pour les connexions) egal à 1 ou -1
function genererPoids()
	local var = 1
	if math.random() >= 0.5 then
		var = var * -1
	end
	return var
end

-- renvoie l'indice du tableau lesInputs avec les coordonnées x y, peut être utilisé aussi pour acceder aux inputs du réseau de neurone
function getIndiceLesInputs(x, y)
	return x + ((y-1) * NB_TILE_W)
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



function niveauReussi()
	console.log("Le niveau est réussi ! Arrêt du script.")
	terminerScript() -- Nettoyez avant de quitter.
	os.exit()
end
