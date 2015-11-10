

var locomotive = require('locomotive')
    , express = require('express')
    , path = require('path')
    , bootable = require('bootable')
    , connect = require('connect')
    , http = require('http');

var app = express();

locomotive.hello = new Object();

locomotive.phase(locomotive.boot.controllers(path.resolve('.', './app/controllers')));
locomotive.phase(locomotive.boot.views());
locomotive.phase(require('bootable-environment')({
    dirname: path.resolve('.', './config/environments'),
    env: app.settings.env
}));
locomotive.phase(bootable.initializers(path.resolve('.', './config/initializers')));
locomotive.phase(locomotive.boot.routes(path.resolve('.', './config/routes')));
locomotive.phase(function () {
    http.createServer(this.express).listen(4000, 'localhost', function () {
        var addr = this.address();
        console.log('listening on %s:%d', addr.address, addr.port);
    });
});

locomotive.boot(app.settings.env, function (err) {
});

