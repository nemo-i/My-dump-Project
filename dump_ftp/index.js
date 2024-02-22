const path = require('path');
const fs = require('fs');
const express = require('express');
const app = express();
const PORT = 4060;

app.set('view engine', 'ejs');
let data = [];
var data_path = path.join(__dirname, 'data');


app.get("/", (req, res) => {
    res.download("F:\\Books\\CISSP All-in-One Exam Guide, Eighth Edition (2018).pdf");
});



app.listen(PORT, () => {
    console.log("Start Listen On Port 4060");
});


