-- Constantes --
NOM_JEU = "Super Mario World (USA)" -- nom du jeu
NOM_SAVESTATE = "debut.state" -- nom du savestate à charger
NOM_FICHIER_POPULATION = "Generation IDGeneration.pop" -- IDGeneration sera remplacé par le nb de gen

-- Constantes pour l'interface formulaire
TAILLE_FORM_W = 400	-- taille de la fenetre de l'interface formulaire 
TAILLE_FORM_H = 400 -- taille de la fenetre de l'interface formulaire

-- Constantes pour l'interface graphique
TAILLE_TILE = 16-- taille d'une tile DANS LE JEU

TAILLE_VUE_W = TAILLE_TILE * 16 -- taille de ce que je vois le script
TAILLE_VUE_H = TAILLE_TILE * 11 -- taille de ce que je vois le script




TAILLE_CAMERA_W = 176 -- du jeu (en pixel)  (ça fait 25 tiles)
TAILLE_CAMERA_H = 240 -- du jeu (en pixel) (ça fait 20 tiles)
NB_TILE_W = TAILLE_VUE_W / TAILLE_TILE -- nombre de tiles scannée par le réseau de neurone en longueur (ça fait 25)
NB_TILE_H = TAILLE_VUE_H / TAILLE_TILE -- nombre de tiles scannée par le réseau de neurone en largeur  (ça fait 20)
NB_SPRITE_MAX = 11 -- dans SMW, il y a au maximum 12 sprites à l'écran en meme temps (en fait c'est 11+1 car 0 est un sprite), pour chaque type de sprite (à ne pas modifier)

TAILLE_INPUT = 4 -- en pixel, uniquement pour l'affichage
TAILLE_HIDDEN = 2 -- en pixel, uniquement pour l'affichage
TAILLE_OUTPUT_W = 10 -- en pixel, rectangle button A, B, X, Y, Up, Down, Left, Right
TAILLE_OUTPUT_H = 5 -- en pixel, rectangle button A, B, X, Y, Up, Down, Left, Right
ENCRAGE_X_INPUT = 10 -- en pixel, uniquement pour l'affichage
ENCRAGE_Y_INPUT = 40 -- en pixel, uniquement pour l'affichage
ENCRAGE_X_HIDDEN = 100 -- en pixel, uniquement pour l'affichage
ENCRAGE_Y_HIDDEN = 40 -- en pixel, uniquement pour l'affichage
ENCRAGE_X_OUTPUT = 200 -- en pixel, uniquement pour l'affichage
ENCRAGE_Y_OUTPUT = 40 -- en pixel, uniquement pour l'affichage
ESPACE_Y_OUTPUT = TAILLE_OUTPUT_H + 2.5 -- en pixel, uniquement pour l'affichage (espace entre chaque output)
NB_HIDDEN_PAR_LIGNE = 10 -- nombre de neurone hidden par ligne (affichage uniquement)

FITNESS_LEVEL_FINI = 1000000 -- quand le level est fini, la fitness devient ça
NB_FRAME_RESET_BASE = 30 -- si pendant x frames la fitness n'augmente pas comparé à celle du début, on relance (le jeu tourne à 30 fps au cas où)
NB_FRAME_RESET_PROGRES = 350 -- si il a eu un progrés (diff de la fitness au lancement) on laisse le jeu tourner un peu + longtemps avant le reset
NB_NEURONE_MAX = 100000 -- pour le reseau de neurone, hors input et output
NB_INPUT = NB_TILE_W * NB_TILE_H -- nb de neurones input, c'est chaque case du jeu en fait
NB_OUTPUT = 8 -- nb de neurones output, c'est à dire les touches de la manette
NB_INDIVIDU_POPULATION = 100 -- nombre d'individus créés quand création d'une nouvelle population

-- Constantes pour trier les espèces des populations
EXCES_COEF = 0.50 -- Coefficient pour déterminer l'importance des gènes en excès lors du calcul de la distance génétique
POIDSDIFF_COEF = 0.92 -- Coefficient pour déterminer l'importance des différences de poids lors du calcul de la distance génétique
DIFF_LIMITE = 1.00 -- Limite de distance génétique pour déterminer si deux individus appartiennent à la même espèce

-- Constantes pour les mutations
CHANCE_MUTATION_RESET_CONNEXION = 0.20 -- Probabilité que le poids d'une connexion soit complètement réinitialisé lors d'une mutation
POIDS_CONNEXION_MUTATION_AJOUT = 0.75 -- Poids ajouté à la mutation d'une connexion si CHANCE_MUTATION_RESET_CONNEXION n'est pas appliqué. La valeur peut être négative.
CHANCE_MUTATION_POIDS = 0.90 -- Probabilité de mutation des poids des connexions
CHANCE_MUTATION_CONNEXION = 0.80 -- Probabilité de mutation des connexions (ajout/suppression de connexions)
CHANCE_MUTATION_NEURONE = 0.35 -- Probabilité de mutation des neurones (ajout/suppression de neurones)

-- doit correspondre aux inputs de la manette dans l'emulateur
lesBoutons = {
	{nom = "P1 A"},
	{nom = "P1 B"},
	{nom = "P1 X"},
	{nom = "P1 Y"},
	{nom = "P1 Up"},
	{nom = "P1 Down"},
	{nom = "P1 Left"},
	{nom = "P1 Right"}
}
nbInnovation = 0 -- nombre d'innovation global pour les connexions, important pour le reseau de neurone
fitnessMax = 0 -- fitness max atteinte 
nbGeneration = 1 -- pour suivre on est à la cb de generation
idPopulation = 1 -- quel id de la population est en train de passer dans la boucle
marioBase = {} -- position de mario a la base ça va me servir pour voir si il avance de sa position d'origine / derniere pos enregistrée
niveauFini = false
lesAnciennesPopulation = {} -- stock les anciennes population
nbFrame = 0 -- nb de frame actuellement
nbFrameStop = 0 -- permettra de reset le jeu au besoin
fitnessInit = 0 -- fitness à laquelle le reseau actuel commence est init
niveauFiniSauvegarde = false
lesEspeces = {}
laPopulation = {}