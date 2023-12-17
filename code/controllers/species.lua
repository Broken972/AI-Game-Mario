-- Crée une nouvelle espèce (un regroupement de réseaux, d'individus)
function newEspece()
    local espece = {
        nbEnfant = 0,            -- Nombre d'enfants que cette espèce a créé
        fitnessMoyenne = 0,      -- Fitness moyenne de l'espèce
        fitnessMax = 0,          -- Fitness maximale atteinte par l'espèce
        lesReseaux = {}          -- Tableau qui regroupe les réseaux de l'espèce
    }

    return espece
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
