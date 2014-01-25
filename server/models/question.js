var mongoose = require('mongoose');

var questionSchema = mongoose.Schema({
  question: String,
  choices: [{
    choice: String,
    count: { type: Number, default: 0 }
  }],
  answers: { type: Array, default: [] },
  created_on: Date
});

questionSchema.pre('save', function(next) {
  if (!this.created_on) {
    this.created_on = new Date;
  }

  next();
});

var Question = mongoose.model('Question', questionSchema);

module.exports = Question;