var bhttp = require('bhttp')
var request = require('request')
var redis = require('redis')

exports.handler = (event, context, callback) => {
	console.log("========start======")
	console.log(event);
	console.log("------------context----------");
	console.log(context);
	console.log("-------------code---------");
	//code grant
	var code = event.body.code;
	var key = event.headers.myheader;
	console.log(code);
	//request header content type
	const options = {
		headers: {
		  'Content-Type': 'application/x-www-form-urlencoded',
		},
	};
	//key is blank
	if(key == undefined || key == "" || key == null){
		//get amazone login access token
		bhttp.post('https://api.amazon.com/auth/o2/token', 'grant_type=authorization_code&code='+code+'&client_id=<amazon-client-id>&client_secret=<amazon-secret>', options).then(response => {
			const body = response.body;
			console.log('------------------token body---------------------');
			console.log(body);
			//token variable
			var token = body.access_token;
			console.log('------------token-----------------');
			console.log(token);
			//redis cache token and create random str to used for cookie
			var client = redis.createClient(6379, 'amazon-login-cache.sx4bhp.ng.0001.use2.cache.amazonaws.com');
			client.on('error', function(error){
				console.log('-----redis error----' + error);
			});
			key = Math.random().toString(36).substring(7);
			console.log('------------set key-------' + key);
			client.set(key, token, redis.print);
			client.quit();
			//get amazon user info
			request('https://api.amazon.com/user/profile?access_token=' + token, function (error, response, body) {
				console.log('--------------user info body----------------');
				console.log(body);
				var hh = {'body':body, 'headers':key};
				console.log(hh);
				//lambda callback
				callback(null, hh);
			})
		});
	}else{
		var client = redis.createClient(6379, 'amazon-login-cache.sx4bhp.ng.0001.use2.cache.amazonaws.com');
		client.get(key, function(error, value){
			console.log('------error----');
			console.log(error);
			console.log('--------------redis value--------');
			console.log(value);
			//validate value(token)
			//get amazon user info
			request('https://api.amazon.com/user/profile?access_token=' + value, function (error, response, body) {
				console.log('--------------user info body----------------');
				console.log(body);
				var hh = {'body':body, 'headers':key};
				console.log(hh);
				client.quit();
				//lambda callback
				callback(null, hh);
			})
		});
	}
};
