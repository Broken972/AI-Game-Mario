function traitementPause()
	local lesBoutons = joypad.get(1)
	if lesBoutons["P1 Start"] then
		lesBoutons["P1 Start"] = false
	else
		lesBoutons["P1 Start"] = true
	end
	joypad.set(lesBoutons)
end

-- Gère la fermeture du script
event.onexit(function()
	console.log("Fin du script")  -- Affiche un message lors de la fin du script
	gui.clearGraphics()  -- Nettoie les graphiques de l'interface utilisateur
	forms.destroy(form)  -- Détruit le formulaire (fenêtre)
end)