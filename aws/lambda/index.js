var bhttp = require('bhttp')
var request = require('request')

exports.handler = (event, context, callback) => {
	//code grant
	var code = event.code;
	console.log(code);
	//request header content type
	const options = {
		headers: {
		  'Content-Type': 'application/x-www-form-urlencoded',
		},
	};
	//get amazone login access token
	bhttp.post('https://api.amazon.com/auth/o2/token', 'grant_type=authorization_code&code='+code+'&client_id=<amazon client id>&client_secret=<amazon secret key>', options).then(response => {
		const body = response.body;
		console.log(body);
		//token variable
		var token = body.access_token;
		console.log(token);
		//get amazon user info
		request('https://api.amazon.com/user/profile?access_token=' + token, function (error, response, body) {
			console.log(body);
			//lambda callback
			callback(null, body);
	})
	});
};
