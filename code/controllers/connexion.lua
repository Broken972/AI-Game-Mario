-- Crée une nouvelle connexion
function newConnexion()
    local connexion = {}
    
    connexion.entree = 0       -- Identifiant du neurone d'entrée de la connexion
    connexion.sortie = 0       -- Identifiant du neurone de sortie de la connexion
    connexion.actif = true     -- État de la connexion (active ou non)
    connexion.poids = 0        -- Poids de la connexion
    connexion.innovation = 0   -- Numéro d'innovation de la connexion
    connexion.allume = false   -- Pour le dessin, si true cela signifie que le résultat de la connexion est différent de 0

    return connexion
end

-- Ajoute une connexion à un réseau de neurones
function ajouterConnexion(unReseau, entree, sortie, poids)
    -- Vérifie si les neurones de la connexion existent bien
    if unReseau.lesNeurones[entree].id == 0 then
        console.log("La connexion avec l'entrée " .. entree .. " n'est pas initialisée ?")
        return
    end
    if unReseau.lesNeurones[sortie].id == 0 then
        console.log("La connexion avec la sortie " .. sortie .. " n'est pas initialisée ?")
        return
    end
    
    local connexion = newConnexion()
    connexion.actif = true
    connexion.entree = entree
    connexion.sortie = sortie
    connexion.poids = genererPoids()
    connexion.innovation = nbInnovation
    table.insert(unReseau.lesConnexions, connexion)
    nbInnovation = nbInnovation + 1
end

-- Ajoute une connexion entre 2 neurones pas déjà connectés entre eux
-- Ça peut ne pas marcher si aucun neurone n'est connectable entre eux (uniquement si beaucoup de connexions)
function mutationAjouterConnexion(unReseau)
    local liste = {}

    -- Randomisation + copies des neurones dans une liste
    for i, v in ipairs(unReseau.lesNeurones) do
        local pos = math.random(1, #liste + 1)
        table.insert(liste, pos, v)
    end

    -- Recherche des neurones sans connexion et création d'une connexion si possible
    local traitement = false
    for i = 1, #liste do
        if traitement then break end

        for j = 1, #liste do
            if i == j then goto continue end

            local neurone1 = liste[i]
            local neurone2 = liste[j]

            if (neurone1.type == "input" and neurone2.type == "output") or
               (neurone1.type == "hidden" and neurone2.type == "hidden") or
               (neurone1.type == "hidden" and neurone2.type == "output") then
                -- Vérification de l'existence d'une connexion entre les deux neurones
                local dejaConnexion = false
                for k = 1, #unReseau.lesConnexions do
                    local connexion = unReseau.lesConnexions[k]
                    if connexion.entree == neurone1.id and connexion.sortie == neurone2.id then
                        dejaConnexion = true
                        break
                    end
                end

                if not dejaConnexion then
                    -- Nouvelle connexion, traitement terminé
                    traitement = true
                    ajouterConnexion(unReseau, neurone1.id, neurone2.id)
                    break
                end
            end

            ::continue::
        end
    end

    if not traitement then
        console.log("impossible de créer une nouvelle connexion")
    end
end
