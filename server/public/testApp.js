simply.text({title:'Clickr', body:'The quiz app'}, true);

simply.on('singleClick', function(e) {
	if (e.button === 'up') {
		simply.body('UP you go!');
	} else if (e.button === 'down') {
		simply.body('DOWN you go!');
	}
});
