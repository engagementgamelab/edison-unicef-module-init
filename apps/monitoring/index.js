var express = require('express');
var app = express();

app.get('/', function (req, res) {
  res.send('Monitoring');
});

app.set('port', 8080);

app.listen(app.get('port'), function () {
  console.log('Monitoring listening on port ' + app.get('port'));
});