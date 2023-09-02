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