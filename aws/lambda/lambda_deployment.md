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