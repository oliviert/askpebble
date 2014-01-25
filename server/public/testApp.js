simply.text({title:'Clickr', subtitle:'The quiz app'}, true);

simply.on('singleClick', function(e) {
	ajax({ url: 'https://raw2.github.com/oliviert/askpebble/master/server/public/question.json' }, function(data) {
        var data = JSON.parse(data);
        simply.subtitle(data.question, true);
        for(var choice in data.choices) {
                body += (choice+1) + '. ' + data.choices[choice] + '\n';
        }
        simply.body(body);
        simply.scrollable(true);
});
});
