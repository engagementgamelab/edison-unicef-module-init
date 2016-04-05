var express = require('express');
var app = express();

app.get('/', function (req, res) {
  res.send('Downloader');
});

app.set('port', (process.env.PORT || 3000));

app.listen(app.get('port'), function () {
  console.log('Downloader listening on port ' + app.get('port'));
});