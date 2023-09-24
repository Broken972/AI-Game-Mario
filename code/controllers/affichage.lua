-- dessine les informations actuelles
function dessinerLesInfos(laPopulation, lesEspeces, nbGeneration)
	gui.drawBox(0, 0, 256, 36, "black", "white")

	gui.drawText(0, 4, "Generation " .. nbGeneration .. " Ind:" .. idPopulation .. " nb espece " .. 
							#lesEspeces .. "\nFitness:" .. 
							laPopulation[idPopulation].fitness .. " (max = " .. fitnessMax .. ")", "black")
end

function resetFitnessMax()
    fitnessMax = 0
end