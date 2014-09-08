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

    _this.findCoordinatesAndExecute = function(postcode, methodParamSuccess, methodParamError) {
        var filteredCode = postcode.toUpperCase().replace(/[^A-Z0-9]/g, "");
        var key = "AIzaSyBG_RQQigx8WsMaYH9dxe1hQVYlhbTZHro"
        var address = "https://maps.googleapis.com/maps/api/geocode/json?address=London+" + filteredCode + "+UK&key=" + key;
        console.log('Postcode is ' + filteredCode);
        console.log('Request to google: ', address);
        var lng = 0;
        var lat = 0;
        var errorMethod = function(xhr) {
            console.error("Geocode API error (JSON): ", xhr);
        };
        var successMethod = function(data) {
            if (data.error_message) {
                console.error("Geocode API error: ", data.error_message);
            } else {
                if (data.results[0].formatted_address == "London, UK") {
                    methodParamError();
                    return;
                }
            }
            console.log('success');
            lng = data.results[0].geometry.location.lng;
            lat = data.results[0].geometry.location.lat;
            methodParamSuccess({'lng': lng, 'lat': lat});
        };
        var coordinates = loadJSON(address, successMethod, errorMethod);
    };

    _this.calculateDistance = function(userLng, userLat, storedLng, storedLat) {
        var maths = new Maths();
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

    // Returns distance between two points in kilometres
    _this.calculateDistancesForAllWarehouses = function(userLng, userLat, returnMethod) {
        console.log('Calculating lng and lat for warehouses');
        var address = "/warehouses/addresses.json";
        var errorMethod = function(xhr) {
            console.error("JSON acess error: ", xhr);
        };
        var fetchMethod = function(data) {
            console.log('JSON success');
            var mapUtil = new MapUtility();
            for (var i = 0; i < data.warehouses.length; i++) {
                var warehouseId = data.warehouses[i].id;
                var warehouseAddress = data.warehouses[i].address;
                var warehouseDistance = data.warehouses[i].distance;
                var deliverable = false;
                mapUtil.locateAndDo(warehouseAddress,
                function(data) {
                    var distanceKm = mapUtil.calculateDistance(userLng, userLat, data.results[0].geometry.location.lng, data.results[0].geometry.location.lat);
                    var distanceMile = mapUtil.kmToMile(distanceKm);
                    if (distanceMile <= warehouseDistance) {
                        deliverable = true;
                    }
                    console.log(distanceMile, ' miles');
                    console.log('deliverable', deliverable);
                    returnMethod(deliverable);
                },
                function() {
                    console.log('Failed calculate distance');
                });
            };
        };
        loadJSON(address, fetchMethod, errorMethod);
    };
}