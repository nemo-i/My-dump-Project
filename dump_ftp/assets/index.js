const express = rqurei
const app = express();

// Route to accept string from terminal
app.get("/", (req, res) => {
  const string = req.query.string;
  console.log("Received string:", string);
  res.send("String received successfully.");
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

// Accept string from command-line argument
const stringValue = process.argv[2];
if (stringValue) {
  console.log("Received string from command line:", stringValue);
}
