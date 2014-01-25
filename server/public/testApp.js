simply.text({title:'Clickr', subtitle:'The QUIZ App'}, true);
var state = "question";
simply.on('singleClick', function(e) {
	ajax({ url: 'https://raw2.github.com/oliviert/askpebble/master/server/public/question.json' }, function(data) {
        var data = JSON.parse(data);
        simply.subtitle(data.question, true);
        var body = '';
        for(var choice in data.choices) {
                body += (choice+1) + '. ' + data.choices[choice] + '\n';
        }
        simply.body(body);
        simply.scrollable(true);
	});
});

function postAnswer(){
	ajax({method:'post', url: 'ENTER URL HERE', data:{pebbleId:Pebble.getAccountToken(), questionId:'id for the question', answerId:'selected ans'}}, function(data){
		getNextQuestion();
	});
};