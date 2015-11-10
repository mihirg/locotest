//var express = require('express');
var assets = require ('connect-assets');
var express = require('express');
var APP_ROOT = __dirname + '/../..';

module.exports = function() {
    this.set('views', __dirname + '/../../app/views');
    if (process.env.NODE_ENV != '') {
        this.set('env', process.env.NODE_ENV);
    }
    // allows for templating via ejs templates
    this.set('view engine', 'ejs');
    // this hooks up connect-assets to the middleware. now <% directives in ejs templates
    // get resolved via this plugin.
    this.use(assets({
        src: "/app/assets",
        servePath: "/assets",
        build: true,
        paths: [    APP_ROOT + "/app/assets/js",
            APP_ROOT + "/public/assets/js",
            APP_ROOT + "/app/assets/css"
             ]
    }));

    this.use(this.router);
    this.use(express.compress());
    this.use(express.bodyParser());
    this.use(express.cookieParser());
    //this.use(require(__dirname + '/../../app/middleware/origin'));
/*    this.use(timeout(90000, {
        respond: true
    }));
    this.use(function(req, res, next){
        console.log("PID#" + process.pid + "url: " + req.url);
        next();
    });
    this.use(express.static(__dirname + '/../../public')); */
};
