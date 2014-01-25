ajax({ url: 'https://raw2.github.com/oliviert/askpebble/master/server/public/question.json' }, function(data) {
	var data = JSON.parse(data);
	simply.title('');
	simply.subtitle("JAUHAR SHABBIR BASRAI");
	
	var body = '';
	for(var choice in data.choices) {
		body += choice + '. ' + data.choices[choice] + '\n';
	}
	simply.body(body);
});
