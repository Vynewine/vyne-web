function MapUtility() {
    "use strict";
    var _this = this;
    _this.key = "AIzaSyAYpKRqaf8jYVoxl39_Y1mXnHZ9sJbBTHY";

    // Finds latitude and longitude
    _this.locate = function (postcode, callbackMethod) {
        // postcode = "SW6-6 ha";
        var filteredCode = postcode.toUpperCase().replace(/[^A-Z0-9]/g, "");
        var key = _this.key;
        var address = "https://maps.googleapis.com/maps/api/geocode/json?address=London+" + filteredCode + "+UK&key=" + key;
        console.log(address);
        var errorMethod = function (xhr) {
            console.error("Geocode API error (JSON): ", xhr);
        };
        loadJSON(address, callbackMethod, errorMethod);
    };
}