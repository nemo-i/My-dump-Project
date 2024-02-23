const path = require('path');
const fs = require('fs');
const express = require('express');
const app = express();
const PORT = 4060;

app.set('view engine', 'ejs');
let data = [];
var data_path = path.join(__dirname, 'data');

app.get("/download", (req, res) => {
    res.send(200);
    res.download(req);
});





app.listen(PORT, () => {
    console.log("Start Listen On Port 4060");
});


