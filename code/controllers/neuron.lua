local function newNeurone()
    return {
        valeur = 0,
        id = 0,
        type = ""
    }
end

local function ajouterNeurone(unReseau, id, type, valeur)
    if id ~= 0 then
        local neurone = newNeurone()
        neurone.id = id
        neurone.type = type
        neurone.valeur = valeur
        table.insert(unReseau.lesNeurones, neurone)
    else
        console.log("ajouterNeurone ne doit pas être utilisé avec un id == 0")
    end
end

return {
    newNeurone = newNeurone,
    ajouterNeurone = ajouterNeurone
}
