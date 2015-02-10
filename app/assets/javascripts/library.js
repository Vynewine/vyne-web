/**
 * Little handy mathematical functions.
 */
function Maths() {
    "use strict";
    var _this = this;
    _this.fixangle = function (a) {
        return a - 360.0 * Math.floor(a / 360.0);
    };
    _this.torad = function (d) {
        return d * Math.PI / 180.0;
    };
    _this.todeg = function (r) {
        return r * 180.0 / Math.PI;
    };
    _this.dsin = function (d) {
        return Math.sin(_this.torad(d));
    };
    _this.dcos = function (d) {
        return Math.cos(_this.torad(d));
    };
    _this.compareLessThanElement = function (element, index, array) {
        return (this < element);
    };
}

/**
 * Little handy JSON function.
 * Re-factor!
 */
var postJSON = function (path, token, data, success, error) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                if (success)
                    return success(JSON.parse(xhr.responseText));
            } else {
                if (error) {
                    error(xhr);
                    return -1;
                }
            }
        }
    };
    xhr.open("POST", path, true);
    xhr.setRequestHeader('X-CSRF-Token', token);
    xhr.setRequestHeader('Accept', 'application/json');
    xhr.setRequestHeader('Content-Type', 'application/json');
    // xhr.setRequestHeader('Content-Length', data.length);
    xhr.send(JSON.stringify(data));
    // xhr.send(data);
};

var ieVersion = function msieversion() {

    var ua = window.navigator.userAgent;
    var msie = ua.indexOf("MSIE ");

    if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) {
        return parseInt(ua.substring(msie + 5, ua.indexOf(".", msie)))
    } else {
        return 0;
    }
};


String.prototype.capitalise = function () {
    return this.charAt(0).toUpperCase() + this.slice(1);
};