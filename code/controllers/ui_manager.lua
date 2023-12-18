function creerUI()
    form = forms.newform(TAILLE_FORM_W, TAILLE_FORM_H, "Informations")
    initializeUI()
end

function initializeUI()
    -- Création des éléments de l'interface utilisateur
    labelInfo = forms.label(form, "À mettre à jour", 0, 0, 350, 220)
    estAccelere = forms.checkbox(form, "Accélérer", 10, 220)
    estAfficheReseau = forms.checkbox(form, "Réseau", 10, 240)
    estAfficheInfo = forms.checkbox(form, "Bandeau", 10, 260)
    -- Boutons d'action
    forms.button(form, "Pause", traitementPause, 10, 285)
    forms.button(form, "Sauvegarder", activerSauvegarde, 10, 315)
    forms.button(form, "Charger", activerChargement, 100, 315)
    forms.button(form, "Réinitialiser fitness max", resetFitnessMax, 100, 285)
end

function gererAffichage()
    nettoyer = not (forms.ischecked(estAfficheReseau) or forms.ischecked(estAfficheInfo))

    emu.limitframerate(not forms.ischecked(estAccelere))

    if forms.ischecked(estAfficheReseau) then
        dessinerUnReseau(laPopulation[idPopulation])
    end

    if forms.ischecked(estAfficheInfo) then
        dessinerLesInfos(laPopulation, lesEspeces, nbGeneration)
    end

    if nettoyer then
        gui.clearGraphics()
    end
end

function afficherInformations()
    str = "Génération " .. nbGeneration .. " Fitness maximal: " .. fitnessMax ..
                "\nInformations sur l'individu actuel:\n" ..
                "id: " .. idPopulation .. "/" .. #laPopulation .. 
                " neurones: " .. #laPopulation[idPopulation].lesNeurones ..
                " connexions: " .. #laPopulation[idPopulation].lesConnexions ..
                " enfant de l'espèce " .. laPopulation[idPopulation].idEspeceParent ..
                "\n\nInfos sur les espèces:\nIl y a " .. #lesEspeces .. " espèce(s)"

    for i = 1, #lesEspeces do
        str = str .. "\nEspèce " .. i .. " a fait " .. lesEspeces[i].nbEnfant ..
                    " enfant(s) (fitness max " .. lesEspeces[i].fitnessMax .. ") "
    end
    forms.settext(labelInfo, str)
end
