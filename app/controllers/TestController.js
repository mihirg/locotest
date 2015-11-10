var locomotive = require('locomotive');

var Controller = locomotive.Controller;

var TestController = new Controller();

TestController.index = function () {
    console.log("MIHIR TEST")
    this.render('codepair');
}

module.exports = TestController;