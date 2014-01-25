ajax({ url: 'https://raw2.github.com/oliviert/askpebble/master/server/public/question.json' }, function(data) {
	var data = JSON.parse(data);
	simply.title('Question');
	simply.subtitle(data.question);
	
	var body = '';
	for(var choice in choices) {
		body += choice;
	}
	simply.body(body);
});