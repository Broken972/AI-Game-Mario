const express = require("express");
const router = express.Router();

// Importation du gestionnaire
const { Update } = require("../updates/handlers");

// Définition de la route POST /update
router.post("/", Update);

module.exports = router;
