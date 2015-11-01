var express = require('express');
var serveStatic = require('serve-static');
var app = express();

var argv = require('yargs')
  .default('port', 8000)
  .argv;

app.use(serveStatic('dist'));

app.get('*', function (req, res) {
  res.sendFile('index.html', {
    root: __dirname + '/../dist'
  });
});

app.listen(argv.port);
