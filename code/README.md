# IA pour Super Mario

Ce projet implémente une IA basée sur un réseau de neurones pour jouer à Super Mario World et Super Mario Bros. L'IA utilise un algorithme génétique pour faire évoluer ses stratégies au fil du temps. Ce document fournit une vue d'ensemble de la structure du projet et explique les concepts clés utilisés dans le code.

## Table des Matières

1. [Introduction](#introduction)
2. [Structure du Projet](#structure-du-projet)
3. [Concepts Clés](#concepts-clés)
    - [Génome](#génome)
    - [Espèce](#espèce)
    - [Pool](#pool)
    - [Réseau de Neurones](#réseau-de-neurones)
4. [Configuration](#configuration)
5. [Comment Ça Marche](#comment-ça-marche)
6. [Exécution de l'IA](#exécution-de-lia)

## Introduction

Ce projet utilise un réseau de neurones et un algorithme génétique pour entraîner une IA à jouer aux jeux Super Mario. L'IA fonctionne sur l'émulateur BizHawk et peut gérer les ROMs de Super Mario World et Super Mario Bros. Le réseau de neurones évolue au fil des générations, apprenant à améliorer ses performances dans le jeu.

## Structure du Projet

-   `main.lua`: Le point d'entrée du programme.
-   `controllers/`
    -   `config.lua`: Paramètres de configuration et constantes.
    -   `fileio.lua`: Fonctions pour la lecture et l'écriture de fichiers.
    -   `game.lua`: Fonctions liées à l'état du jeu et à la lecture de la mémoire.
    -   `genome.lua`: Fonctions liées à la gestion des génomes.
    -   `gui.lua`: Fonctions liées à l'interface graphique.
    -   `network.lua`: Fonctions liées aux opérations du réseau de neurones.
    -   `pool.lua`: Fonctions liées à la gestion du pool génétique.
    -   `species.lua`: Fonctions liées à la gestion des espèces.
    -   `utils.lua`: Fonctions utilitaires.

## Concepts Clés

### Génome

Un **génome** représente un réseau de neurones dans le contexte de cet algorithme génétique. Il contient des gènes qui définissent la structure et les poids du réseau de neurones.

-   **Gène**: Une connexion entre deux neurones, incluant son poids et son numéro d'innovation.
-   **Taux de Mutation**: Probabilités qui contrôlent comment le génome mute au fil des générations.

### Espèce

Une **espèce** est un groupe de génomes similaires. L'algorithme génétique maintient des espèces pour préserver la diversité dans la population.

-   **Fitness Maximum**: Le score de fitness le plus élevé atteint par un génome de l'espèce.
-   **Stagnation**: Une mesure du nombre de générations pendant lesquelles une espèce n'a pas amélioré son fitness maximum.
-   **Fitness Moyenne**: Le score de fitness moyen des génomes de l'espèce.

### Pool

Le **pool** est la structure principale qui gère toutes les espèces et génomes. Il suit l'état actuel de l'algorithme génétique, y compris la génération actuelle et les meilleurs scores de fitness.

-   **Population**: Le nombre total de génomes dans le pool.
-   **Génération**: Le numéro de la génération actuelle de l'algorithme.

### Réseau de Neurones

Le **réseau de neurones** est constitué de neurones et de connexions (gènes) entre ces neurones. Il est utilisé pour prendre des décisions de jeu en fonction des entrées reçues.

-   **Neurone**: Unité de base du réseau de neurones, recevant des entrées et produisant une sortie après application d'une fonction d'activation (comme la sigmoid).

## Configuration

Le fichier `config.lua` contient tous les paramètres de configuration et les constantes utilisés dans le projet, tels que les noms de fichiers de sauvegarde, les boutons de contrôle, les taux de mutation, etc.

## Comment Ça Marche

1. **Initialisation**: L'IA commence par créer un pool de génomes aléatoires.
2. **Évaluation**: Chaque génome joue le jeu et reçoit un score de fitness basé sur sa performance.
3. **Sélection**: Les meilleurs génomes sont sélectionnés pour se reproduire et créer une nouvelle génération de génomes.
4. **Mutation et Crossover**: Les génomes sélectionnés subissent des mutations et des croisements pour introduire de la variation.
5. **Répétition**: Le processus se répète pour un nombre donné de générations ou jusqu'à ce que l'IA atteigne une performance satisfaisante.

## Exécution de l'IA

Pour exécuter l'IA, assurez-vous que BizHawk est configuré correctement avec les ROMs de Super Mario World ou Super Mario Bros. Ensuite, chargez et exécutez le script `main.lua` dans BizHawk.

---

Ce fichier `README.md` devrait vous donner une compréhension complète du projet et de ses composants. Pour toute question supplémentaire, veuillez consulter le code source ou contacter les développeurs.
