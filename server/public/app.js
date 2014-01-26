var uuid = Pebble.getAccountToken();
var get_url = 'http://askpebble.herokuapp.com/questions/12345';
var post_url = 'http://askpebble.herokuapp.com/answer';

var questionBuffer = [];
var data, choices, selectedChoice;
var choiceMap = ["A", "B", "C", "D"];

getQuestions(function(response) {
	nextQuestion();
});

function getQuestions(callback) {
	ajax({ url: get_url }, function(response) {
		questionBuffer = JSON.parse('[{"__v":0,"_id":"52e45453204ca402005a4029","created_on":"2014-01-26T00:18:27.096Z","question":"Favorite color?","answers":["54321"],"choices":[{"choice":"Red","_id":"52e45453204ca402005a402a","count":0},{"_id":"52e45453204ca402005a402b","choice":"Green","count":1}]}]');
		if(callback) {
			callback(response);
		}
	});
}

function nextQuestion() {
	clearFields();
	data = questionBuffer.shift();
	if(data) {
		questionLoop();
		getQuestions();
	}
	else {
		simply.title('No questions');
	}
}

function questionLoop() {
	registerQuestionLoopEvents();
	renderQuestion(data);
}

function registerQuestionLoopEvents() {
	clearListeners();
	simply.on('singleClick', function(e) {
		if(e.button === 'select') {
			answerLoop();
		}
	});
	simply.scrollable(true);
}

function renderQuestion() {
	simply.text({
		body: data.question
	}, true);
}

function answerLoop() {
	registerAnswerLoopEvents();
	renderAnswers();
}

function registerAnswerLoopEvents() {
	clearListeners();
	simply.on('singleClick', function(e) {
		if(e.button === 'up') {
			prevChoice();
		}
		else if(e.button === 'down') {
			nextChoice();
		}
		else if(e.button === 'select') {
			postAnswer();
		}
	});	
	simply.on('longClick', function(e) {
		if(e.button === 'select') {
			questionLoop();
		}
	})
	simply.scrollable(false);	
}

function renderAnswers() {
	if(!choices) {
		selectedChoice = 0;
		updateChoices(data.choices);
	}
	renderChoices();
}

function updateChoices(c) {
	choices = c;
	choices.push({
		_id: '0',
		choice: 'Skip'
	});
}

function nextChoice() {
	if(selectedChoice === choices.length - 1) {
		selectedChoice = 0;
	}
	else {
		selectedChoice++;
	}
	renderChoices();
}

function prevChoice() {
	if(selectedChoice === 0) {
		selectedChoice = choices.length -1
	}
	else {
		selectedChoice--;
	}
	renderChoices();
}

function renderChoices() {
	simply.body(formatChoices());
}

function formatChoices() {
	var output = '';
	for(var i=0; i < choices.length; i++) {
		var choice = choices[i].choice;
		if(selectedChoice === i) {
			output += '>';
		}
		output += choiceMap[i] + '. ' + choice + '\n';
	}
	return output;
}

function clearListeners() {
	simply.off('singleClick');
	simply.off('longClick');
}

function postAnswer() {
	ajax({
		method: 'post',
		url: post_url,
		data: {
			uuid: '12345',
			qid: data._id,
			aid: choices[selectedChoice]._id,
		}
	}, function() {
		nextQuestion();
	});
}

function clearFields() {
	choices = selectedChoice = null;
}
