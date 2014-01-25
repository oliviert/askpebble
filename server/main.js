'use strict';

var express = require('express');
var app = express();

app.set('port', process.env.PORT || 3000);

app.use(express.logger());
app.use(express.bodyParser());

app.post('/ask', function(req, res) {
  res.send('received');
});

app.get('/questions', function(req, res) {
  res.send('questions');
});

app.listen(app.get('port'), function() {
  console.log('Server listening on port ' + app.get('port'));
});