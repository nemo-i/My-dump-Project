const path = require('path');
const fs = require('fs');
const express = require('express');
const app = express();
const PORT = 4060;


const data = [];
app.get('/', (req, res) => {
    fs.readdir(__dirname, (err, files) => {
        for (const file of files) {
            data.push(file);
        }
    });
    res.send(data);
});



app.listen(PORT, () => {
    console.log("Start Listen On Port 4060");
});


