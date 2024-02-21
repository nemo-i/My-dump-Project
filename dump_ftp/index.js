const path = require('path');
const fs = require('fs');
const express = require('express');
const app = express();
const PORT = 4060;

app.set('view engine', 'ejs');
let data = [];
var data_path = path.join(__dirname, 'data');
app.get('/', (req, res) => {
    fs.readdir(data_path, (err, files) => {
        data = [];
        for (const file of files) {
            var ob = {
                name: file,
                location: path.join(__dirname, file),
            };
            data.push(ob);
        }
        console.log(data);
    })
    res.render('index', {
        data: data
    });

});



app.listen(PORT, () => {
    console.log("Start Listen On Port 4060");
});


