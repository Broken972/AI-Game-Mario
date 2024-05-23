-- créé une espece (un regroupement de reseaux, d'individus)
function newEspece() 
	local espece = {nbEnfant = 0, -- combien d'enfant cette espece a créé 
					fitnessMoyenne = 0, -- fitness moyenne de l'espece
					fitnessMax = 0, -- fitness max atteinte par l'espece
					lesReseaux = {} }-- tableau qui regroupe les reseaux}
 
 
	return espece
end
 

-- modifie les connexions d'un reseau de neurone
function mutationPoidsConnexions(unReseau)
	for i = 1, #unReseau.lesConnexions, 1 do
		if unReseau.lesConnexions[i].actif then
			if math.random() < CHANCE_MUTATION_RESET_CONNEXION then
				unReseau.lesConnexions[i].poids = genererPoids()
			else
				if math.random() >= 0.5 then
					unReseau.lesConnexions[i].poids = unReseau.lesConnexions[i].poids - POIDS_CONNEXION_MUTATION_AJOUT
				else
					unReseau.lesConnexions[i].poids = unReseau.lesConnexions[i].poids + POIDS_CONNEXION_MUTATION_AJOUT
				end
			end
		end
	end
end

-- ajoute une connexion entre 2 neurones pas déjà connecté entre eux
-- ça peut ne pas marcher si aucun neurone n'est connectable entre eux (uniquement si beaucoup de connexion)
function mutationAjouterConnexion(unReseau)
	local liste = {}
 
	-- randomisation + copies des neuronnes dans une liste
	for i, v in ipairs(unReseau.lesNeurones) do
		local pos = math.random(1, #liste+1)
		table.insert(liste, pos, v)
	end
 
	-- la je vais lister tous les neurones et voir si une pair n'a pas de connexion; si une connexion peut être créée 
	-- on la créée et on stop
	local traitement = false
	for i = 1, #liste, 1 do
		for j = 1, #liste, 1 do
			if i ~= j then
				local neurone1 = liste[i]
				local neurone2 = liste[j]
 
 
				if (neurone1.type == "input" and neurone2.type == "output") or
					(neurone1.type == "hidden" and neurone2.type == "hidden") or
					(neurone1.type == "hidden" and neurone2.type == "output") then
					-- si on en est là, c'est que la connexion peut se faire, juste à tester si y pas deja une connexion
					local dejaConnexion = false
					for k = 1, #unReseau.lesConnexions, 1 do
						if unReseau.lesConnexions[k].entree == neurone1.id
							and unReseau.lesConnexions[k].sortie == neurone2.id then
							dejaConnexion = true
							break
						end
					end
 
 
 
					if dejaConnexion == false then
						-- nouvelle connexion, traitement terminé 
						traitement = true
						ajouterConnexion(unReseau, neurone1.id, neurone2.id)
					end
				end
			end
			if traitement then 
				break
			end
		end
		if traitement then 
			break
		end
	end
 
 
	if traitement == false then
		console.log("impossible de recreer une connexion")
	end
end
 
 
-- ajoute un neurone (couche caché uniquement) entre 2 neurones déjà connecté. Ne peut pas marcher
-- si il n'y a pas de connexion 
function mutationAjouterNeurone(unReseau)
	if #unReseau.lesConnexions == 0 then
		log("Impossible d'ajouter un neurone entre 2 connexions si pas de connexion")
		return nil
	end
 
	if unReseau.nbNeurone == NB_NEURONE_MAX then
		console.log("Nombre de neurone max atteint")
		return nil
	end
 
	-- randomisation de la liste des connexions
	local listeIndice = {}
	local listeRandom = {}
 
	-- je créé une liste d'entier de 1 à la taille des connexions
	for i = 1, #unReseau.lesConnexions, 1 do
		listeIndice[i] = i
	end
 
	-- je randomise la liste que je viens de créer dans listeRandom
	for i, v in ipairs(listeIndice) do
		local pos = math.random(1, #listeRandom+1)
		table.insert(listeRandom, pos, v)
	end
 
	for i = 1, #listeRandom, 1 do
		if unReseau.lesConnexions[listeRandom[i]].actif then
			unReseau.lesConnexions[listeRandom[i]].actif = false
			unReseau.nbNeurone = unReseau.nbNeurone + 1
			local indice = unReseau.nbNeurone + NB_INPUT + NB_OUTPUT 
			ajouterNeurone(unReseau, indice, "hidden", 1)
			ajouterConnexion(unReseau, unReseau.lesConnexions[listeRandom[i]].entree, indice, genererPoids())
			ajouterConnexion(unReseau, indice, unReseau.lesConnexions[listeRandom[i]].sortie, genererPoids())
			break
		end
	end
end
 
 
-- appelle une des mutations aléatoirement en fonction des constantes
function mutation(unReseau)
	local random = math.random()
	if random < CHANCE_MUTATION_POIDS then
		mutationPoidsConnexions(unReseau)
	end
	if random < CHANCE_MUTATION_CONNEXION then
		mutationAjouterConnexion(unReseau)
	end
	if random < CHANCE_MUTATION_NEURONE then
		mutationAjouterNeurone(unReseau)
	end
end