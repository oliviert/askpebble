var url = 'https://raw2.github.com/oliviert/askpebble/master/server/public/question.json';
var choices = [];
var selectedChoice = 0;
var choiceMap = ["A", "B", "C", "D"];
var qid;

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

getNextQuestion();

function postAnswer(){
	ajax({
		method:'post', 
		url: '/', 
		data: { 
			pebbleId : Pebble.getAccountToken(), 
			questionId : qid, 
			answerId : choices[selectedChoice]._id
		}
	}, function(data){
		getNextQuestion();
	});
};

function getNextQuestion() {
	ajax({ url: url }, function(data) {
		qid = data._id;
		selectedChoice = 0;
		updateChoices(data.choices);
		simply.text({
			subtitle: data.question,
			body: formatChoices(data.choices)
		}, true);	
	});
}

function updateChoices(c) {
	choices = c;
	choices.push({
		_id: '0',
	});
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
	for(var i=0; i < choices.length; i++) {
		if(selectedChoice === i) {
			output += '>'
		}
		output += choiceMap[i] + '. ' + choices[i] + '\n';
	}
	output += choiceMap[choices.length] + '. Skip';
	return output;
}