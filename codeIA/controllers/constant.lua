-- constantes

local CONSTANTS = {
    -- Jeu et fichiers
    GAME_NAME = "Super Mario World (USA)",
    SAVESTATE_NAME = "debut.state",
    POPULATION_FILE = "gen idGen.pop",  -- idGen sera remplacé par le nb de gen

    -- Dimensions du jeu et de la vue
    FORM_WIDTH = 380,
    FORM_HEIGHT = 385,
    TILE_SIZE = 16,  -- Taille d'une tile dans le jeu
    VIEW_WIDTH = 16 * 11,  -- Largeur de la vue en pixels
    VIEW_HEIGHT = 16 * 9,  -- Hauteur de la vue en pixels
    CAMERA_WIDTH = 256,  -- Largeur de la caméra du jeu
    CAMERA_HEIGHT = 224,  -- Hauteur de la caméra du jeu
    TILE_COUNT_WIDTH = 11,  -- Nombre de tiles en largeur dans la vue
    TILE_COUNT_HEIGHT = 9,  -- Nombre de tiles en hauteur dans la vue
    MAX_SPRITE_COUNT = 11,  -- Maximum de sprites à l'écran en même temps (0-11)
    
    -- Affichage des réseaux de neurones
    DISPLAY = {
        INPUT_SIZE = 6,  -- Taille des neurones d'entrée en pixels
        HIDDEN_SIZE = 4,  -- Taille des neurones cachés en pixels
        OUTPUT_WIDTH = 24,  -- Largeur des neurones de sortie en pixels
        OUTPUT_HEIGHT = 8,  -- Hauteur des neurones de sortie en pixels
        ANCHOR_X_INPUT = 20,
        ANCHOR_Y_INPUT = 50,
        ANCHOR_X_HIDDEN = 100,
        ANCHOR_Y_HIDDEN = 50,
        ANCHOR_X_OUTPUT = 190,
        ANCHOR_Y_OUTPUT = 50,
        OUTPUT_SPACING_Y = 13,  -- Espacement vertical entre les sorties en pixels
        HIDDEN_PER_ROW = 10  -- Nombre de neurones cachés par ligne
    },
    
    -- Fitness et reset
    FITNESS_LEVEL_FINISHED = 10000,  -- Niveau de fitness pour considérer le niveau comme terminé
    BASE_FRAME_RESET = 33,  -- Nombre de frames avant le reset de base
    PROGRESS_FRAME_RESET = 350,  -- Nombre de frames avant le reset en cas de progression

    -- Réseau de neurones
    MAX_NEURON_COUNT = 50000,  -- Nombre maximum de neurones
    INPUT_COUNT = 11 * 9,  -- Nombre d'entrées (TILE_COUNT_WIDTH * TILE_COUNT_HEIGHT)
    OUTPUT_COUNT = 5,  -- Nombre de sorties (touches de la manette)

    -- Population
    POPULATION_SIZE = 100,  -- Nombre d'individus dans une population

    -- Constantes pour le tri des espèces
    SPECIES = {
        EXCESS_COEF = 0.50,
        WEIGHT_DIFF_COEF = 0.92,
        DIFFERENCE_THRESHOLD = 1.00
    },

    -- Mutation
    MUTATION = {
        CONNECTION_RESET_CHANCE = 0.30,  -- Probabilité de réinitialisation d'une connexion
        CONNECTION_WEIGHT_ADDITION = 0.80,  -- Probabilité d'ajout de poids de connexion
        WEIGHT_MUTATION_CHANCE = 0.90,  -- Probabilité de mutation de poids
        CONNECTION_MUTATION_CHANCE = 0.85,  -- Probabilité de mutation de connexion
        NEURON_MUTATION_CHANCE = 0.35  -- Probabilité de mutation de neurone
    },
    
    -- Inputs de la manette
    BUTTONS = {
        {name = "P1 A"},  -- Sauter
        {name = "P1 Y"},  -- Courir
        {name = "P1 Down"},
        {name = "P1 Left"},
        {name = "P1 Right"}
    },

    -- Variables globales pour le réseau de neurones et la population
    GLOBALS = {
        innovation_number = 0,  -- Nombre d'innovations globales pour les connexions
        max_fitness = 0,  -- Fitness maximale atteinte
        generation_number = 1,  -- Numéro de génération actuel
        population_id = 1,  -- ID de la population en cours
        mario_base_position = {},  -- Position initiale de Mario
        level_finished = false,  -- Indicateur de niveau terminé
        previous_populations = {},  -- Stockage des anciennes populations
        current_frame_count = 0,  -- Nombre de frames actuelles
        frame_stop_count = 0,  -- Pour le reset du jeu
        initial_fitness = 0,  -- Fitness initiale
        level_finished_saved = false,  -- Indicateur de sauvegarde de niveau terminé
        species_list = {},  -- Liste des espèces
        population = {}  -- Population actuelle
    }
}

return CONSTANTS
