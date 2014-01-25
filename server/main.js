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
var User = require('./models/user');

app.set('port', process.env.PORT || 3000);

app.use(express.logger());
app.use(express.bodyParser());
app.use(express.static(process.cwd() + '/public'));

app.post('/ask', function(req, res) {
  var choices = req.body.choices;

  var question = new Question({ question: req.body.question });
  for (var i = 0; i < choices.length; i++) {
    question.choices.push({ choice: choices[i], count: 0 });
  }

  question.save(function(err) {
    if (!err) {
      res.send(200);
    } else {
      console.log(err);
      res.send(400);
    }
  });
});

app.get('/questions', function(req, res) {
  var now = new Date();
  var today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  Question.find({ created_on: {$gte: today }}, function(err, questions) {
    res.send(questions);
  });
});

app.post('/answer', function(req, res) {
  User.findOne({ uuid: req.body.uuid }, function(err, user) {
    if (!user) {
      user = new User({ uuid: req.body.uuid, answers: [req.body.qid] });
      user.save();
      console.log(user);
    } else {
      for (var i = 0; i < user.answers.length; i++) {
        if (user.answers[i] == req.body.aid) {
          res.json(400, { error: { message: 'Question already answered.'}});
          return;
        }
      }

      user.answers.push(req.body.qid);
      user.save();
      res.send({ response: { message: 'Success!' }});
    }
  });

  Question.update({ _id: req.body.qid, 'choices._id': req.body.aid }, { $inc: { 'choices.$.count': 1 }}, function(err) {
    if (err) {
      res.send(400);
    } else {
      res.send(200);
    }
  });
  res.send(200);
});

app.listen(app.get('port'), function() {
  console.log('Server listening on port ' + app.get('port'));
});