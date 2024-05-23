-- constantes

-- Jeu et fichiers
local CONSTANTS = {
    GAME_NAME = "Super Mario World (USA)",
    SAVESTATE_NAME = "debut.state",
    POPULATION_FILE = "gen idGen.pop",  -- idGen sera remplacé par le nb de gen

    -- Dimensions
    FORM_WIDTH = 380,
    FORM_HEIGHT = 385,
    TILE_SIZE = 16,  -- taille d'une tile DANS LE JEU
    VIEW_WIDTH = 16 * 11,  -- TILE_SIZE * 11
    VIEW_HEIGHT = 16 * 9,  -- TILE_SIZE * 9
    CAMERA_WIDTH = 256,  -- du jeu
    CAMERA_HEIGHT = 224,
    TILE_COUNT_WIDTH = 11,  -- VIEW_WIDTH / TILE_SIZE
    TILE_COUNT_HEIGHT = 9,  -- VIEW_HEIGHT / TILE_SIZE
    MAX_SPRITE_COUNT = 11,  -- Maximum 12 sprites à l'écran en même temps (0-11)
    
    -- Affichage
    DISPLAY = {
        INPUT_SIZE = 6,  -- en pixel
        HIDDEN_SIZE = 4,  -- en pixel
        OUTPUT_WIDTH = 24,  -- en pixel
        OUTPUT_HEIGHT = 8,  -- en pixel
        ANCHOR_X_INPUT = 20,
        ANCHOR_Y_INPUT = 50,
        ANCHOR_X_HIDDEN = 100,
        ANCHOR_Y_HIDDEN = 50,
        ANCHOR_X_OUTPUT = 190,
        ANCHOR_Y_OUTPUT = 50,
        OUTPUT_SPACING_Y = 13,  -- OUTPUT_HEIGHT + 5
        HIDDEN_PER_ROW = 10  -- nombre de neurones hidden par ligne
    },
    
    -- Fitness et reset
    FITNESS_LEVEL_FINISHED = 10000,
    BASE_FRAME_RESET = 33, -- 33
    PROGRESS_FRAME_RESET = 350, -- 300
    
    -- Réseau de neurones
    MAX_NEURON_COUNT = 50000,
    INPUT_COUNT = 11 * 9,  -- TILE_COUNT_WIDTH * TILE_COUNT_HEIGHT
    OUTPUT_COUNT = 5,  -- touches de la manette
    
    -- Population
    POPULATION_SIZE = 100,  -- 100 nombre d'individus créés pour une nouvelle population

    -- Spécies sorting constants
    SPECIES = {
        EXCESS_COEF = 0.50,
        WEIGHT_DIFF_COEF = 0.92,
        DIFFERENCE_THRESHOLD = 1.00
    },

    -- Mutation
    MUTATION = {
        CONNECTION_RESET_CHANCE = 0.30, -- 0.25
        CONNECTION_WEIGHT_ADDITION = 0.80,
        WEIGHT_MUTATION_CHANCE = 0.90,
        CONNECTION_MUTATION_CHANCE = 0.85,
        NEURON_MUTATION_CHANCE = 0.35
    },
    
    -- Inputs de la manette
    BUTTONS = {
        {name = "P1 A"},  -- sauter
        {name = "P1 Y"},  -- courir
        {name = "P1 Down"},
        {name = "P1 Left"},
        {name = "P1 Right"}
    },

    -- Variables globales pour le réseau de neurones et la population
    GLOBALS = {
        innovation_number = 0,  -- nombre d'innovation global pour les connexions
        max_fitness = 0,  -- fitness max atteinte
        generation_number = 1,  -- pour suivre le nombre de générations
        population_id = 1,  -- id de la population en cours
        mario_base_position = {},  -- position initiale de Mario
        level_finished = false,
        previous_populations = {},  -- stockage des anciennes populations
        current_frame_count = 0,  -- nombre de frames actuelles
        frame_stop_count = 0,  -- pour le reset du jeu
        initial_fitness = 0,  -- fitness initiale
        level_finished_saved = false,
        species_list = {},
        population = {}
    }
}

return CONSTANTS
