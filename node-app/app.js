const express = require('express');
const app = express();  // Create an Express application instance.
const port = 8080;  // The port on which this application is listening.

// Use ejs as the templating engine.
app.engine('html', require('ejs').renderFile);

// Middleware to enable Cross-Origin Resource Sharing (CORS)
app.use((req, res, next) => {
   res.header('Access-Control-Allow-Origin', '*');
   res.header('Access-Control-Allow-Methods', 'GET');
   next();
});

// Serve static files from the 'public' directory.
app.use(express.static('public'));

// Define a route for the root URL ("/").
app.get('/', async (req, res) => {
   // Use the fetch API to make an asynchronous HTTP request to an external resource.
   const response = await fetch("http://" + process.env.BACKEND_DOMAIN_NAME + '/test');
   const time = await response.text();

   // Check if the response headers indicate a cached response.
   if (response.headers.get("x-cache") === "HIT") {
      res.render(__dirname + '/views/cache.html', {root: __dirname, time: time});
      console.log(`Answered cached request (${response.headers.get("x-varnish")})`);
   }

   // Serve the default HTML file if the response is not cached.
   else {
      res.render(__dirname + '/views/index.html', {root: __dirname, time: time});
      console.log('Answered request');
   }
});

// Define a route for '/test'.
app.get('/test', async (req, res) => {

   // Get the current time and send it as a response.
   const time = new Date().toTimeString().split(' ')[0];
   res.send(time);
});

// Start the Express application and listen on the specified port.
app.listen(port, () => {
   console.log(`Node.js Application is listening on port ${port}`);
});
