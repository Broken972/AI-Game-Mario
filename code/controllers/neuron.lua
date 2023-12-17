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