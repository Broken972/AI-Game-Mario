-- Charger la DLL en utilisant le nom complet de l'assembly
local HttpHelperLibrary = luanet.load_assembly("HttpHelperLibrary")

-- Importer la classe HttpHelper
local HttpHelper = luanet.import_type("HttpHelperLibrary.HttpHelper")

-- Effectuer la requête HTTP GET
local response = HttpHelper.Get("http://127.0.0.1:8080")

-- Afficher la réponse
print(response)
