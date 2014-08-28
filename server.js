require("coffee-script/register");
var debug = require('getdebug')(__filename);

var app = module.exports = require("./lib/server");

app.listen(3000);
debug('Listening on 127.0.0.1:3000');
