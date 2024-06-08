let Update = (req, res) => {
    var io = req.app.get("io");
    var data = req.body;

    // Validation de la donnée reçue (optionnel)
    if (!data || !data.instance_id || !data.score || !data.status) {
        return res.status(400).send({ error: "Invalid data" });
    }

    io.emit("update", data); // Émettre les données via Socket.io
    res.status(200).send("Update received");
};

module.exports = {
    Update,
};
