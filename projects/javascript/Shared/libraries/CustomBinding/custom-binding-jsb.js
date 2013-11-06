app = app || {};
app.__async = {
	callbackFunctions: {},
	count: 0,
	
	callback: function(id, params){
		if(!id) return;
		var cb = this.callbackFunctions[id];
		if(!cb){
			// error
			return;
		}
		this.callbackFunctions[id] = null;
		delete this.callbackFunctions[id];
		cb.apply(app, [params]);
	}


};
app.__event = {
	callbackFunctionsAndUserValues: {},
	callback: function(id, params){
		
		if(!id) return;
		var pairs = this.callbackFunctions[id];
		if(!pairs){
			return;
		}
		for(var i in pairs){
			var pair = pairs[i];
			
			var cb = pair[0];
			var userValue = pair[1];
			if(!cb){
				return;
			}
			cb.apply(app, [params, userValue]);
		}
	}
}
if(!app.command){
	app.command = function(name, params){
		alert('app.command not available in this platform. (' + name + ')');
	};
}
app.async = function(name, data, callback){
	var id = ++app.__async.count;
	app.__async.callbackFunctions[id] = callback;
	app.command('__async-' + name, {
		"data": data,
		"id": id
	});
}
app.bind = function(name, userValue, callback){
	if(!app.__event.callbackFunctionsAndUserValues[name]){
		app.__event.callbackFunctionsAndUserValues[name] = [];
		app.command('__event-bind-' + name, {});
	}
	app.__event.callbackFunctionsAndUserValues[name].push([callback, userValue]);
}
app.unbind = function(name, userValue){
	
	if(arguments.length == 1){
		app.__event.callbackFunctionsAndUserValues[name] = null;
		delete app.__event.callbackFunctionsAndUserValues[name];
		app.command('__event-unbind-' + name, {});
		return;
	}
	var pairs = app.__event.callbackFunctionsAndUserValues[name];
	
	var newPairs = [];
	for(var i in pairs){
		var pair = pairs[i];
		var uv = pair[1];
		if(uv != userValue){
			newPairs.push(pair);
		}
	}
	if(newPairs.length){
		app.__event.callbackFunctionsAndUserValues[name] = newPairs;
		return;
	}
	
	app.__event.callbackFunctionsAndUserValues[name] = null;
	delete app.__event.callbackFunctionsAndUserValues[name];
	app.command('__event-unbind-' + name, {});
}