const express = require("express");
const path = require("path");
const app = express();

app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname + "/manageUser.html"));
})

app.post('/user.html',function(req,res){
    res.sendFile(path.join(__dirname + "/user.html"));
}
);

app.post('/home.html',function(req,res){
    res.sendFile(path.join(__dirname + "/home.html"));
}
);

app.post('/manageUser.html',function(req,res){
    res.sendFile(path.join(__dirname + "/manageUser.html"));
}
);

app.post('/manageDurian.html',function(req,res){
    res.sendFile(path.join(__dirname + "/manageDurian.html"));
}
);

app.post('/distributor.html',function(req,res){
    res.sendFile(path.join(__dirname + "/distributor.html"));
}
);

app.post('/distributorManageDurian.html',function(req,res){
    res.sendFile(path.join(__dirname+"/distributorManageDurian.html"))
})

app.post('/retailer.html',function(req,res){
    res.sendFile(path.join(__dirname+"/retailer.html"))
})

app.post('/buyDurianPage.html',function(req,res){
    res.sendFile(path.join(__dirname+"/buyDurianPage.html"))
})

app.post('/history.html',function(req,res){
    res.sendFile(path.join(__dirname+"/history.html"))
})

app.post('/review.html',function(req,res){
    res.sendFile(path.join(__dirname+"/review.html"))
})




app.use(express.static(path.join(__dirname, '/public')));


const server = app.listen(5000);
const portNumber = server.address().port;
console.log(`port is open on ${portNumber}`);