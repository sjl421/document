## Lambda Function Deployment Package
1. make a directory and make sure all source code, file and nodejs library into the smae directory.
2. intall node and npm tool,example Mac OS


```
brew install node
node --version
npm --version
```

3. use the follow commands at your shell prompt

```
mkdir codeLogin
cd codeLogin
npm install request bhttp
touch index.js

```

4. look the directory

```
ls -lF
index.js
node_modules/
```

5. make a zip package

```
zip ../codeLogin.zip -r *
```

6. index.js structure like this：

```
exports.handler = (event, context, callback) => {
	callback(null, 'Hello World!');
};
```

7. perhaps problem

[unsupported grant type error](https://sellercentral.amazon.com/forums/thread.jspa?threadID=342557&tstart=0)  

8. Help link and docs

[Amazon API Gateway + AWS Lambda + OAuth](https://www.authlete.com/documents/apigateway_lambda_oauth_step1)  
[Authorization Code Grant](https://developer.amazon.com/docs/login-with-amazon/authorization-code-grant.html)  
[login-with-amazon](https://github.com/stevegula/login-with-amazon)  
[Login with Amazon](https://login.amazon.com/documentation)  
[Login with Amazon Developer Guide for Websites](https://images-na.ssl-images-amazon.com/images/G/01/lwa/dev/docs/website-developer-guide._TTH_.pdf)  

