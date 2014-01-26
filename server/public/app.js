var uuid = Pebble.getAccountToken().toString();
var get_url = 'http://askpebble.herokuapp.com/questions/' + uuid;
var post_url = 'http://askpebble.herokuapp.com/answer';

var questionBuffer = [];
var data, choices, selectedChoice;
var choiceMap = ["A", "B", "C", "D", "E"];

var noQuestions = false;
var interval;

getQuestions(function(response) {
	nextQuestion();
});

function getQuestions(callback) {
	ajax({ url: get_url }, function(response) {
		questionBuffer = JSON.parse(response);
		if(callback) {
			callback(response);
		}
	});
}

function nextQuestion() {
	clearFields();
	data = questionBuffer.shift();
	if(data) {
		noQuestions = false;
		questionLoop();
	}
	else {
		if(noQuestions) {
			clearListeners();
			simply.text({ title: 'No more questions' }, true);
			setTimeout(function() {
				getQuestions(function() {
					nextQuestion();
				});	
			}, 5000)			
		}
		else {
			noQuestions = true;
			getQuestions(function() {
				nextQuestion();
			});
		}
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
			uuid: uuid,
			qid: data._id,
			aid: choices[selectedChoice]._id,
		}
	}, function() {
		resultLoop();
	});
}

function resultLoop() {
	registerResultLoopEvents();
	renderResults();
}

function registerResultLoopEvents() {
	clearListeners();
	simply.on('singleClick', function(e) {
		if(e.button === 'select') {
			clearInterval(interval)
			nextQuestion();
		}
	});
	simply.scrollable(true);
}

function renderResults() {
	var results;	
	interval = setInterval(function() {
		ajax({ url: 'http://askpebble.herokuapp.com/question/' + data._id }, function(response) {
			var output = '';
			results = ericsMethod(JSON.parse(response));
			for(var i=0; i < results.length; i++) {
				var result = results[i];
				output += choiceMap[i] + '. ' + result.bars 
					+ ' ' + result.votes + '\n    ' + result.choice
					+ '\n';
			}
			simply.style('small');
			simply.text({
				body: output
			}, true);
		});
	}, 2000);
}

function ericsMethod(response) {
	var choices = response.choices;
	var maxBars = 25;
	var maxVotes = -1;
	var results = [];

	for(var i=0; i < choices.length; i++) {
		if(choices[i].count > maxVotes) {
			maxVotes = choices[i].count; 
		}
	}

	for(var i=0; i < choices.length; i++) {
		var result = {};
		result.votes = choices[i].count;

		var bars = '';
		for(var k=0; k < result.votes * maxBars / maxVotes; k++) {
			bars += '|';
		}
		result.bars = bars;
		result.choice = choices[i].choice;
		results.push(result);
	}

	return results;
}

function clearFields() {
	choices = selectedChoice = null;
}
