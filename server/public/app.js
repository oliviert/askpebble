var url = 'https://raw2.github.com/oliviert/askpebble/master/server/public/question.json';
var data, choices, selectedChoice;
var choiceMap = ["A", "B", "C", "D"];

getQuestion(function(response) {
	clearFields();
	displayQuestionLoop();
});

function getQuestion(callback) {
	ajax({ url: url }, function(response) {
		data = JSON.parse(response);
		callback(response);
	});
}

function displayQuestionLoop() {
	displayQuestionEvents();
	displayQuestionRender(data);
}

function displayQuestionEvents() {
	clearListeners();
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

function selectAnswerRender() {
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
	getQuestion();
}

function clearFields() {
	choices = selectedChoice = null;
}