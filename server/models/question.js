var mongoose = require('mongoose');

var Question = mongoose.model('Question', {
	_id: Number,
	date: Date,
	question: String,
	choices: [{
		choice: String
	}]
});

module.exports = Question;