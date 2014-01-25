var mongoose = require('mongoose');

var Question = mongoose.model('Question', {
	date: Date,
	question: String,
	choices: [{
		choice: String
	}]
});

module.exports = Question;