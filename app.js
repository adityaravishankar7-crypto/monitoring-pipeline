const express = require('express');
const app = express();
const port = 80;

app.get('/', (req, res) => {
  res.send('<h1>Application Hello World - Deployed via Pipeline!</h1>');
});

// A mock metrics endpoint for your monitoring tool to scrape
app.get('/metrics', (req, res) => {
  res.json({
    status: "healthy",
    uptime: process.uptime(),
    memoryUsage: process.memoryUsage().heapUsed
  });
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});