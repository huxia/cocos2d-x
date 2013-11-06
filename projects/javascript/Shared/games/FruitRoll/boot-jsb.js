/*
 Watermelon With Me
 Boot file for JSB
 */

// JS Bindings constants
require("jsb.js");

// resource file
require('resources-jsb.js');

// Level file
require('levels.js');

// game file
require('watermelon_with_me.js');


app.async('test',{
			'hi': 'hello',
			'ok': 1233.23,
			'array': [1,2,3,'sdsd',{'a':23}]
		  },function(data){
		  cc.log(data.hello);
		  });