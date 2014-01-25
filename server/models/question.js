var mongoose = require('mongoose');

var Question = mongoose.model('Question', {
	created_on: Date,
	question: String,
	choices: [{
		id: String,
		choice: String
	}]
});

questionSchema.pre('save', function(next) {
  if (!this.created_on)
    this.created_on = new Date;

  next();
});

var Question = mongoose.model('Question', questionSchema);

module.exports = Question;