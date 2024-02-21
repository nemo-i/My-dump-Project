const path = require('path');
const fs = require('fs');

console.log(__dirname);

fs.readdir(__dirname, (err, files) => {
    for (const file of files) {
        console.log(file);
    }
});
