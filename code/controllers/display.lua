function dessinerUnReseau(unReseau)
    -- Préparation des variables
    local lesInputs = getLesInputs()
    local lesPositions = {}

    -- Dessin des neurones d'entrée
    for i = 1, NB_TILE_W do
        for j = 1, NB_TILE_H do
            local indice = getIndiceLesInputs(i, j)
            local xT, yT = calculerPosition(i, j, ENCRAGE_X_INPUT, ENCRAGE_Y_INPUT, TAILLE_INPUT)
            local couleurFond = determinerCouleurFond(unReseau.lesNeurones[indice].valeur)
            gui.drawRectangle(xT, yT, TAILLE_INPUT, TAILLE_INPUT, "black", couleurFond)
            lesPositions[indice] = {x = xT + TAILLE_INPUT / 2, y = yT + TAILLE_INPUT / 2}
        end
    end

    -- Dessin de Mario pour la visualisation
    dessinerMario(unReseau)

    -- Dessin des sorties
    dessinerSorties(unReseau, lesPositions)

    -- Dessin des neurones cachés
    dessinerNeuronesCaches(unReseau, lesPositions)

    -- Dessin des connexions
    dessinerConnexions(unReseau, lesPositions)
end

function dessinerLesInfos(laPopulation, lesEspeces, nbGeneration)
	gui.drawBox(0, 0, 256, 36, "black", "white")
	gui.drawText(0, 4, "Génération:" .. nbGeneration .. "Id:" .. idPopulation .. " nbEspece:" .. 
							#lesEspeces .. "\nDistance:" .. 
							laPopulation[idPopulation].fitness .. " (max = " .. fitnessMax .. ")", "black")
end


function calculerPosition(i, j, encrageX, encrageY, taille)
    return encrageX + (i - 1) * taille, encrageY + (j - 1) * taille
end

function determinerCouleurFond(valeur)
    if valeur < 0 then return "black"
    elseif valeur > 0 then return "white"
    else return "gray" end
end

function dessinerMario(unReseau)
    local marioPos = convertirPositionPourInput(getPositionMario())
    local x, y = calculerPosition(marioPos.x, marioPos.y, ENCRAGE_X_INPUT, ENCRAGE_Y_INPUT, TAILLE_INPUT)
    gui.drawRectangle(x, y, TAILLE_INPUT, TAILLE_INPUT * 2, "black", "blue")
end

function dessinerSorties(unReseau, lesPositions)
    for i = 1, NB_OUTPUT do
        local xT = ENCRAGE_X_OUTPUT
        local yT = ENCRAGE_Y_OUTPUT + ESPACE_Y_OUTPUT * (i - 1)
        local nomT = string.sub(lesBoutons[i].nom, 4)
        local indice = i + NB_INPUT
        local couleurFond = sigmoid(unReseau.lesNeurones[indice].valeur) and "white" or "black"
        gui.drawRectangle(xT, yT, TAILLE_OUTPUT_W, TAILLE_OUTPUT_H, "white", couleurFond)
        
        local strValeur = string.format("%.2f", unReseau.lesNeurones[indice].valeur)
        gui.drawText(xT + TAILLE_OUTPUT_W, yT - 1, nomT, "white", "black", 10)
        
        lesPositions[indice] = {x = xT + TAILLE_OUTPUT_W / 2, y = yT + TAILLE_OUTPUT_H / 2}
    end
end

function dessinerNeuronesCaches(unReseau, lesPositions)
    for i = 1, unReseau.nbNeurone do
        local xT = ENCRAGE_X_HIDDEN + (TAILLE_HIDDEN + 1) * (i - (NB_HIDDEN_PAR_LIGNE * math.floor((i-1) / NB_HIDDEN_PAR_LIGNE)))
        local yT = ENCRAGE_Y_HIDDEN + (TAILLE_HIDDEN + 1) * math.floor((i-1) / NB_HIDDEN_PAR_LIGNE)
        local indice = i + NB_INPUT + NB_OUTPUT
        gui.drawRectangle(xT, yT, TAILLE_HIDDEN, TAILLE_HIDDEN, "black", "white")
        lesPositions[indice] = {x = xT + TAILLE_HIDDEN / 2, y = yT + TAILLE_HIDDEN / 2}
    end
end

function dessinerConnexions(unReseau, lesPositions)
    for _, connexion in ipairs(unReseau.lesConnexions) do
        if connexion.actif then
            local couleur = determinerCouleurConnexion(connexion)
            gui.drawLine(lesPositions[connexion.entree].x, lesPositions[connexion.entree].y, 
                         lesPositions[connexion.sortie].x, lesPositions[connexion.sortie].y, 
                         couleur)
        end
    end
end

function determinerCouleurConnexion(connexion)
    local pixel = connexion.poids > 0 and 255 or 0
    local alpha = connexion.allume and 255 or 25
    return forms.createcolor(pixel, pixel, pixel, alpha)
end
