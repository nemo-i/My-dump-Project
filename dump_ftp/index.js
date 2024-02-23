const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const os = require('os');

const app = express();
const PORT = 4060;
const homeDir = os.homedir();
const savePath = path.join(homeDir, 'dump-ftp');
let data = [];
let toDownload = null;

// Middleware for parsing JSON bodies
app.use(express.json());

// Middleware for CORS
app.use(cors());

// Serve static files from the 'views' directory
app.use(express.static('views'));

// Set EJS as the view engine
app.set('view engine', 'ejs');

// Read directory and populate 'data' array
fs.readdir(savePath, (err, files) => {
    if (err) {
        console.error('Error reading directory:', err);
        return;
    }
    files.forEach((e) => {
        data.push({
            id: data.length + 1,
            title: e,
            location: path.join(savePath, e),
        });
    });
});

// Endpoint to get files information
app.get("/files", (req, res) => {
    res.json(data);
});

// Endpoint to receive data from client and store it for download
app.post("/download", (req, res) => {
    const { id, title, location } = req.body;
    toDownload = req.body;
    console.log(toDownload);
    res.send('Data received successfully!');
});

// Endpoint to trigger file download
app.get('/download', (req, res) => {
    if (!toDownload) {
        return res.status(400).send('No data received from client.');
    }

    const { id, title, location } = toDownload;

    // Check if the file exists
    if (!fs.existsSync(location)) {
        return res.status(404).send('File not found.');
    }

    // Trigger file download
    res.download(location);
});

// Start the server
app.listen(PORT, () => {
    console.log("Server listening on port", PORT);
});
