'use strict';

var express = require('express');
var app = express();
var mongoose = require('mongoose');

if (process.env.NODE_ENV == 'production') {
  app.set('mongo_url', process.env.MONGOHQ_URL);
} else {
  app.set('mongo_url', 'mongodb://localhost:27017/askpebble');
}

mongoose.connect(app.get('mongo_url'));

var Question = require('./models/question');

app.set('port', process.env.PORT || 3000);

app.use(express.logger());
app.use(express.bodyParser());
app.use(express.static(process.cwd() + '/public'));

app.post('/ask', function(req, res) {
  var question = new Question({ question: req.body.question, choices: req.body.choices });
  question.save();
});

app.get('/questions', function(req, res) {
  var now = new Date();
  var today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  Question.find({ created_on: {$gte: today }}, function(err, questions) {
    res.send(questions);
  });
});

app.listen(app.get('port'), function() {
  console.log('Server listening on port ' + app.get('port'));
});