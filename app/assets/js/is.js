(function () {
    var IS;
    if (typeof window.IS === 'undefined') {
        //from YUI
        IS = window.IS = function () {
            var a = arguments, o = null, i, j, d;
            for (i=0; i<a.length; i=i+1) {
                d=(""+a[i]).split(".");
                o=IS;

                // IS is implied, so it is ignored if it is included
                for (j=(d[0] == "IS") ? 1 : 0; j<d.length; j=j+1) {
                    o[d[j]]=o[d[j]] || {};
                    o=o[d[j]];
                }
            }

            return o;

        };
    }
    //support browser not having console w/o errors
    if (typeof console === 'undefined') {
        console = {};
    }
    if (typeof console.log === 'undefined') {
        console.log = function () {
        };
    }
    IS.level = -1;
    IS.getParameters = function (hash) {
        var match,
            pl     = /\+/g,  // Regex for replacing addition symbol with a space
            search = /([^&=]+)=?([^&]*)/g,
            decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
            query  = hash ? window.location.hash.substring(1) : window.location.search.substring(1),
            urlParams = {};

        while (match = search.exec(query)) {
            urlParams[decode(match[1])] = decode(match[2]);
        }
        return urlParams;
    };
    var getLogFn = function (level, trace) {
        var log = function () {
            if (IS.level > level) {
                return;
            }
            if (trace) {
                var strace = new Error().stack || ''
                strace = strace.split('\n').slice(2);
                Array.prototype.push.call(arguments, '\n' + strace.join('\n'));
            }
            //TODO:check for each item, if its a object try to json it & then convert it back again
            console.log.apply(console, arguments);
        };
        return log
    };
    IS.error = getLogFn(3, true);
    IS.info = getLogFn(2, false);
    IS.log = getLogFn(1, false);
    IS.debug = getLogFn(0, true);
})();
