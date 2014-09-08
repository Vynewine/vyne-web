/**
 * Little handy mathematical functions.
 */
function Maths() {
    "use strict";
    var _this = this;
    _this.fixangle = function(a) {
        return a - 360.0 * Math.floor(a/360.0);
    };
    _this.torad = function(d) {
        return d * Math.PI / 180.0;
    };
    _this.todeg = function(r) {
        return r * 180.0 / Math.PI;
    };
    _this.dsin = function(d) {
        return Math.sin(_this.torad(d));
    };
    _this.dcos = function(d) {
        return Math.cos(_this.torad(d));
    };
    _this.compareLessThanElement = function (element, index, array) {
        return (this < element);
    };
}

/**
 * Little handy JSON function.
 */
var loadJSON = function(path, success, error) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
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
    xhr.open("GET", path, true);
    xhr.send();
};

String.prototype.capitalise = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
};