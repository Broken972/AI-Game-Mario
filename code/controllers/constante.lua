-- ########## Constantes pour le jeu ##########

-- Nom du jeu et fichiers associés
NOM_JEU = "Super Mario World (USA)"
NOM_SAVESTATE = "debut.state"
NOM_FICHIER_POPULATION = "Generation IDGeneration.pop" -- IDGeneration sera remplacé par le numéro de génération

-- ########## Constantes pour l'interface formulaire ##########

-- Dimensions de la fenêtre de l'interface formulaire
TAILLE_FORM_W = 400
TAILLE_FORM_H = 400

-- ########## Constantes pour l'interface graphique et le jeu ##########

-- Taille d'une tuile (tile) dans le jeu
TAILLE_TILE = 16

-- Calcul de la taille de la vue du script basée sur la taille des tuiles
TAILLE_VUE_W = TAILLE_TILE * 16
TAILLE_VUE_H = TAILLE_TILE * 11

-- Dimensions de la caméra du jeu
TAILLE_CAMERA_W = 176
TAILLE_CAMERA_H = 240

-- Calcul du nombre de tuiles scannées par le réseau de neurones
NB_TILE_W = TAILLE_VUE_W / TAILLE_TILE
NB_TILE_H = TAILLE_VUE_H / TAILLE_TILE

-- Nombre maximal de sprites à l'écran en même temps dans SMW
NB_SPRITE_MAX = 11

-- ########## Constantes pour l'affichage du réseau de neurones ##########

-- Tailles des différentes couches du réseau
TAILLE_INPUT = 4
TAILLE_HIDDEN = 2
TAILLE_OUTPUT_W = 10
TAILLE_OUTPUT_H = 5

-- Ancrages pour les différents éléments du réseau
ENCRAGE_X_INPUT = 10
ENCRAGE_Y_INPUT = 40
ENCRAGE_X_HIDDEN = 100
ENCRAGE_Y_HIDDEN = 40
ENCRAGE_X_OUTPUT = 200
ENCRAGE_Y_OUTPUT = 40

-- Autres paramètres d'affichage pour le réseau
ESPACE_Y_OUTPUT = TAILLE_OUTPUT_H + 2.5
NB_HIDDEN_PAR_LIGNE = 10

-- ########## Constantes pour la fitness ##########

-- Valeurs pour le calcul de la fitness
FITNESS_LEVEL_FINI = 1000000
NB_FRAME_RESET_BASE = 30
NB_FRAME_RESET_PROGRES = 350
NB_NEURONE_MAX = 100000
NB_INPUT = NB_TILE_W * NB_TILE_H
NB_OUTPUT = 8
NB_INDIVIDU_POPULATION = 100

-- ########## Constantes pour le tri des espèces ##########

-- Coefficients pour le tri des espèces
EXCES_COEF = 0.50
POIDSDIFF_COEF = 0.92
DIFF_LIMITE = 1.00

-- ########## Constantes pour les mutations ##########

-- Probabilités pour les différents types de mutations
CHANCE_MUTATION_RESET_CONNEXION = 0.20
POIDS_CONNEXION_MUTATION_AJOUT = 0.75
CHANCE_MUTATION_POIDS = 0.90
CHANCE_MUTATION_CONNEXION = 0.80
CHANCE_MUTATION_NEURONE = 0.35

-- ########## Correspondance des boutons avec l'émulateur ##########

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

-- ########## Variables globales ##########

-- Ces variables sont initialisées ici mais seront probablement modifiées pendant l'exécution du programme
nbInnovation = 0
fitnessMax = 0
nbGeneration = 1
idPopulation = 1
marioBase = {}
niveauFini = false
lesAnciennesPopulation = {}
nbFrame = 0
nbFrameStop = 0
fitnessInit = 0
niveauFiniSauvegarde = false
lesEspeces = {}
laPopulation = {}
