var url = 'https://raw2.github.com/oliviert/askpebble/master/server/public/question.json';
var choices = [];
var selectedChoice = 0;
var choiceMap = ["A", "B", "C", "D"];

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

function getNextQuestion() {
	ajax({ url: url }, function(data) {
		selectedChoice = 0;
		simply.text({
			subtitle: data.question,
			body: formatChoices(data.choices)
		}, true);	
	});
}

function formatChoices(choices) {
	for(var i = 0; i < choices.length; i++) {
		this.choices[i] = choices[i];
	}
}

function nextChoice() {
	if(selectedChoice > choices.length - 1) {
		selectedChoice = 0;
	}
	else {
		selectedChoice++;
	}
	renderChoices();
}

function prevChoice() {
	if(selectedChoice < 0) {
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
	for(int i=0; i < choices.length; i++) {
		if(selectedChoice === i) {
			output += '>'
		}
		output += choiceMap[i] + '. ' + choices[i] + '\n';
	}
}