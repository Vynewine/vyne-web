var AddressActionCreators = Marty.createActionCreators({
    id: 'AddressActions',
    validatePostcode: function(postcode) {

        var validated = validatePostcode(postcode);

        var valid = false;

        if (validated) {

            valid = true;

            geocodePostcode(postcode, function(latLng) {

                if(latLng.lat && latLng.lng) {

                    this.dispatch(AddressConstants.SET_POSTCODE, postcode, valid, latLng);

                    VyneRouter.transitionTo('check-availability')

                } else {
                    this.dispatch(ErrorConstants.SET_ERRORS, ["We're sorry byt we couldn't find your postcode."]);
                }

            }.bind(this));

        } else {
            this.dispatch(AddressConstants.SET_POSTCODE, postcode, valid);
        }
    },
    // TODO: Should use Marty.rehydrate() for this?
    initiate: function() {

        var postcode = AddressCookieApi.getPostcode();

        if(postcode) {
            geocodePostcode(postcode, function(latLng) {
                if(latLng.lat && latLng.lng) {
                    this.dispatch(AddressConstants.SET_POSTCODE, postcode, true, latLng);
                }
            }.bind(this));
        }
    }
});

var geocodePostcode = function(postcode, callback) {

    var geocoder = new google.maps.Geocoder();

    geocoder.geocode({'address': 'London+' + postcode + '+UK'}, function (results, status) {

        var latLng = {
            lat: null,
            lng: null
        };

        if (status == google.maps.GeocoderStatus.OK) {

            latLng.lat = results[0].geometry.location.lat();
            latLng.lng = results[0].geometry.location.lng();
        }

        callback(latLng)
    });
};