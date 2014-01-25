var uuid = Pebble.getAccountToken();
var domain = 'http://askpebble.herokuapp.com/';
var get_url = new File(domain, 'questions', uuid).toString();
var post_url = new File(domain, '/answer').toString();

var data, choices, selectedChoice;
var choiceMap = ["A", "B", "C", "D"];

getQuestion(function(response) {
	clearFields();
	questionLoop();
});

function getQuestion(callback) {
	ajax({ url: get_url }, function(response) {
		data = JSON.parse(response);
		callback(response);
	});
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
			displayQuestionLoop();
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
			aid: choices[selectedChoice].choice,
		}
	}, function() {
		getQuestion();
	});
}

function clearFields() {
	choices = selectedChoice = null;
}