function MapUtility() {
    "use strict";
    var _this = this;

    // 1 mile = 1.609344 kilometres
    _this.mileToKm = function(miles) {
        return Math.round(miles * 1609344) / 1000000;
    };

    // 1 kilometre = 0 . 621 371 192 237 333 969 617 434 184 363 318 miles
    _this.kmToMile = function(kilometres) {
        return Math.round(kilometres * 621.371192237333) / 1000;
    };

    // Returns distance between two points in kilometres
    _this.calculateDistancesFor = function(userLng, userLat) {
        var maths = new Maths();
        // Dummy data
        var storedLat = 51.4874009;
        var storedLng = -0.2220532;
        // ----------
        var R = 6371; // earth’s radius (mean radius = 6,371km);
        var latitude1       = maths.torad(storedLat);
        var latitude2       = maths.torad(userLat);
        var delta_latitude  = maths.torad(userLat-storedLat);
        var delta_longitude = maths.torad(userLng-storedLng);
        var a = Math.sin(delta_latitude/2) * Math.sin(delta_latitude/2) +
                Math.cos(latitude1) * Math.cos(latitude2) *
                Math.sin(delta_longitude/2) * Math.sin(delta_longitude/2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        var d = R * c;
        return Math.round(d * 1000000) / 1000000; //.toFixed(3)
    };

    // Finds latitude and longitude
    _this.locateAndDo = function(postcode, methodParam) {
        // postcode = "SW6-6 ha";
        var filteredCode = postcode.toUpperCase().replace(/[^A-Z0-9]/g, "");
        var key = "AIzaSyBG_RQQigx8WsMaYH9dxe1hQVYlhbTZHro"
        var address = "https://maps.googleapis.com/maps/api/geocode/json?address=London+" + filteredCode + "+UK&key=" + key;
        console.log(address);
        var errorMethod = function(xhr) {
            console.error("Geocode API error (JSON): ", xhr);
        };
        loadJSON(address, methodParam, errorMethod);
    };
}