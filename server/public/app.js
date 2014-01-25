var url = 'https://raw2.github.com/oliviert/askpebble/master/server/public/question.json';
var data;
var choices;
var choiceMap = ["A", "B", "C", "D"];

function eventLoop() {
	getQuestion(function(data) {
		this.data = data;
		displayQuestionLoop();
		selectAnswerLoop();
	});
}

function getQuestion(callback) {
	ajax({ url: url }, function(data) {
		var data = JSON.parse(data);
		callback(data);
	});
}

function displayQuestionLoop() {
	displayQuestionEvents();
	displayQuestionRender(data);
}

function displayQuestionEvents() {
	simply.off('singleClick');
	simply.on('singleClick', function(e) {
		if(e.button === 'select') {
			selectAnswerLoop();
		}
	});
	simply.scrollable(true);
}

function displayQuestionRender() {
	simply.text({
		body: data.question
	}, true);
}

function selectAnswerLoop() {
	selectAnswerEvents();
	selectAnswerRender();
}

function selectAnswerEvents() {
	simply.off('singleClick');
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
		else if(e.button === 'back') {
			displayQuestionLoop();
		}
	});	
	simply.scrollable(false);	
}

function selectAnswerRender() {
	var selectedAnswer = 0;
	updateChoices(data.choices);
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