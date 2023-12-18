-- Traite l'événement de pause en inversant l'état actuel du bouton "Start"
function traitementPause()
    local lesBoutons = joypad.get(1)
    -- Inverse l'état du bouton "Start"
    lesBoutons["P1 Start"] = not lesBoutons["P1 Start"]
    joypad.set(lesBoutons)
end

-- Gère la fermeture du script
event.onexit(function()
    console.log("Fin du script")  -- Journalise la fin du script
    gui.clearGraphics()  -- Nettoie les graphiques de l'interface utilisateur
    forms.destroy(form)  -- Détruit le formulaire (fenêtre)
    -- Ajouter ici toute autre action nécessaire lors de la fermeture, comme la sauvegarde de l'état
end)
