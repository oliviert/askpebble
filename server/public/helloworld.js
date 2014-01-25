simply.title('Hello World YO!');
simply.subtitle('this is subtitle');
simply.on('singleClick', function(e) {
  simply.subtitle('You quickly pressed the ' + e.button + ' button!');
});
simply.on('longClick', function(e) {
  simply.subtitle('You long pressed the ' + e.button + ' button!');
});
