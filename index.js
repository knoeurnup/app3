const express = require('express');
const app = express();

app.get('/', function(req, res){
	res.send("Hello app3");
});

app.get('/hello', function(req, res){
	res.send("Welcomn is deployed from app3");
});


app.get('/hi', function(req, res){
	res.send("Say hi from app3");
});


app.listen(8080,function(){
	console.log('app is running in port 8080');
})
