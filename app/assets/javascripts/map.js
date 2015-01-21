function MapUtility() {
    "use strict";
    var _this = this;
    _this.key = "AIzaSyAYpKRqaf8jYVoxl39_Y1mXnHZ9sJbBTHY";

    // 1 mile = 1.609344 kilometres
    _this.mileToKm = function (miles) {
        return Math.round(miles * 1609344) / 1000000;
    };

    // 1 kilometre = 0 . 621 371 192 237 333 969 617 434 184 363 318 miles
    _this.kmToMile = function (kilometres) {
        return Math.round(kilometres * 621.371192237333) / 1000;
    };

    _this.findCoordinatesAndExecute = function (postcode, methodParamSuccess, methodParamError) {
        var filteredCode = postcode.toUpperCase().replace(/[^A-Z0-9]/g, "");
        var key = _this.key;
        var address = "https://maps.googleapis.com/maps/api/geocode/json?address=London+" + filteredCode + "+UK&key=" + key;
        var lng = 0;
        var lat = 0;
        var errorMethod = function (xhr) {
            console.error("Geocode API error (JSON): ", xhr);
        };
        var successMethod = function (data) {
            if (data.error_message) {
                console.error("Geocode API error: ", data.error_message);
            } else {
                if (data.results[0].formatted_address == "London, UK") {
                    methodParamError();
                    return;
                }
            }

            lng = data.results[0].geometry.location.lng;
            lat = data.results[0].geometry.location.lat;
            methodParamSuccess({'lng': lng, 'lat': lat});
        };
        var coordinates = loadJSON(address, successMethod, errorMethod);
    };

    _this.calculateDistance = function (userLng, userLat, storedLng, storedLat) {
        var maths = new Maths();
        var R = 6371; // earth’s radius (mean radius = 6,371km);
        var latitude1 = maths.torad(storedLat);
        var latitude2 = maths.torad(userLat);
        var delta_latitude = maths.torad(userLat - storedLat);
        var delta_longitude = maths.torad(userLng - storedLng);
        var a = Math.sin(delta_latitude / 2) * Math.sin(delta_latitude / 2) +
            Math.cos(latitude1) * Math.cos(latitude2) *
            Math.sin(delta_longitude / 2) * Math.sin(delta_longitude / 2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        var d = R * c;
        return Math.round(d * 1000000) / 1000000; //.toFixed(3)
    };

    // Finds latitude and longitude
    _this.locateAndDo = function (postcode, methodParam) {
        // postcode = "SW6-6 ha";
        var filteredCode = postcode.toUpperCase().replace(/[^A-Z0-9]/g, "");
        var key = _this.key;
        var address = "https://maps.googleapis.com/maps/api/geocode/json?address=London+" + filteredCode + "+UK&key=" + key;
        console.log(address);
        var errorMethod = function (xhr) {
            console.error("Geocode API error (JSON): ", xhr);
        };
        loadJSON(address, methodParam, errorMethod);
    };

    _this.calculateDistanceBetween = function (origins, destinations, distances, warehouses, callbackMethod) {

        var mapUtil = new MapUtility(); // recursive! =D

        var service = new google.maps.DistanceMatrixService();

        service.getDistanceMatrix({
                origins: origins,
                destinations: destinations,
                travelMode: google.maps.TravelMode.DRIVING,
                unitSystem: google.maps.UnitSystem.IMPERIAL,
                durationInTraffic: false,
                avoidHighways: false,
                avoidTolls: false
            },
            function (response, status) {
                var distanceKm = 0;
                var distanceMi = 0;
                var dists = [];
                var delivery = {available: false, warehouses: []};

                for (var i = 0; i < response.rows[0].elements.length; i++) {
                    if (response.rows[0].elements[i].status === "OK") {
                        distanceKm = parseInt(response.rows[0].elements[i].distance.value);
                        distanceMi = mapUtil.kmToMile(distanceKm / 1000);
                        dists.push({m: distanceKm, mi: distanceMi});
                        if (distanceMi <= parseInt(distances[i])) {
                            delivery.available = true;
                            delivery.warehouses.push({
                                id: warehouses[i].id,
                                distance: distanceMi,
                                is_open: warehouses[i].is_open,
                                opening_time: warehouses[i].opening_time,
                                closing_time: warehouses[i].closing_time
                            });
                        }
                    }
                }
                $('#sign-up-distances').val(JSON.stringify(dists));
                callbackMethod(delivery);
            });
    };

    _this.calculateDistanceForAllWarehouses = function (postcode, callbackMethod) {
        var locAddress = "/warehouses/addresses.json";

        var warehousesMethod = function (data) {

            if (data.warehouses.length > 0) {
                var mapUtil = new MapUtility(); // recursive! =D
                var allPostcodes = [];
                var allDistances = [];
                var warehouses = [];
                for (var i = 0; i < data.warehouses.length; i++) {
                    warehouses.push({
                        id: data.warehouses[i].id,
                        is_open: data.warehouses[i].is_open,
                        opening_time: data.warehouses[i].opening_time,
                        closing_time: data.warehouses[i].closing_time
                    });
                    allDistances.push(data.warehouses[i].distance);
                    allPostcodes.push(data.warehouses[i].address);
                }
                mapUtil.calculateDistanceBetween([postcode], allPostcodes, allDistances, warehouses, callbackMethod);
            } else {
                callbackMethod({available: false, warehouses: []});
            }
        };

        var errorMethod = function (xhr) {
            console.error("JSON acess error: ", xhr);
        };

        // Fetching warehouse addresses:
        loadJSON(locAddress, warehousesMethod, errorMethod);
    };

}