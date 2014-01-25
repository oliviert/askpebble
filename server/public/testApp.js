Pebble.addEventListener("ready", function() {
	simply.text({title:'Clickr', subtitle:'The quiz app'}, true);

	simply.on('singleClick', function(e) {
		simply.vibe('short');
		ajax({ url: 'https://raw2.github.com/oliviert/askpebble/master/server/public/question.json' }, function(data) {
		        var data = JSON.parse(data);
		        simply.subtitle(data.question, true);
		        var body = '';
		        for(var choice in data.choices) {
		                body += choice + '. ' + data.choices[choice] + '\n';
		        }
		        simply.body(body);
		        simply.scrollable(true);
		});
	});

});
