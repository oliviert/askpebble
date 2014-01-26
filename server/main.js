'use strict';

var express = require('express');
var app = express();
var mongoose = require('mongoose');

if (process.env.NODE_ENV == 'production') {
  app.set('mongoUri', process.env.MONGOHQ_URL);
} else {
  app.set('mongoUri', 'mongodb://localhost:27017/askpebble');
}

mongoose.connect(app.get('mongoUri'));

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
      res.send(200, { qid: question._id });
    } else {
      console.log(err);
      res.send(400);
    }
  });
});

app.get('/questions/:uuid', function(req, res) {
  var now = new Date();
  var today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  Question.find({ created_on: {$gte: today }, answers: { $nin: [req.params.uuid] }}, function(err, questions) {
    res.json(questions);
  });
});

app.get('/question/:id', function(req, res) {
  Question.findOne({ _id: req.params.id }, function(err, question) {
    if (err) {
      res.send(400);
    } else {
      res.json(question);
    }
  });
});

app.post('/answer', function(req, res) {
  /*
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
  */

  // '0' skips a question
  if (!req.body.qid || !req.body.aid || !req.body.uuid) {
    res.send(400);
    return
  }

  if (req.body.aid !== '0') {
    Question.update({ _id: req.body.qid, 'choices._id': req.body.aid, answers: { $nin: [/*req.body.uuid*/] } }, { $inc: { 'choices.$.count': 1 }, $push: { answers: req.body.uuid }}, function(err, question) {
      if (err) {
        res.send(400);
      } else {
        res.send(200);
      }
    });
  }

  Question.findOne({ _id: req.body.qid }, function(err, question) {
    console.log('here');
    var count = 0;
    var sid = setInterval(function() {
      console.log('running');
      count++;
      var rand = parseInt((Math.random() * (question.choices.length)), 10);
      question.choices[rand].count++;
      question.save();
      if (count > 100) {
        clearInterval(sid);
      }
    }, 500);
  });
});

app.listen(app.get('port'), '0.0.0.0', function() {
  console.log('Server listening on port ' + app.get('port'));
});