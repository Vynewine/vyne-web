var AddressStore = Marty.createStore({
    id: 'AddressStore',
    handlers: {
        geocodePostcode: AddressConstants.GEOCODE_POSTCODE,
        validatePostcode: AddressConstants.VALIDATE_POSTCODE,
        receiveCoordinates: AddressConstants.RECEIVE_COORDINATES
    },
    getInitialState: function () {

        return {
            isValidPostcode: AddressCookieApi.isValidPostcode(),
            postcode: AddressCookieApi.getPostcode(),
            latLng: AddressCookieApi.getLatLng()
        };
    },
    getPostcode: function () {
        return this.state['postcode'];
    },
    getLatLng: function () {
        return this.state['latLng'];
    },
    isValidPostcode: function () {
        return this.state['isValidPostcode'];
    },
    validatePostcode: function (postcode) {

        var validated = validatePostcode(postcode);

        if (validated) {
            this.state['isValidPostcode'] = true;
            this.state['postcode'] = postcode;
            AddressCookieApi.setPostcode(postcode);
            AddressCookieApi.setIsValidPostcode(true);

            analytics.track('Postcode validation', {
                postcode: postcode,
                valid: true
            });
        } else {
            this.state['isValidPostcode'] = false;
            this.state['postcode'] = '';
            AddressCookieApi.setPostcode('');
            AddressCookieApi.setIsValidPostcode(false);

            analytics.track('Postcode validation', {
                postcode: postcode,
                valid: false
            });
        }

        this.hasChanged();
    },
    geocodePostcode: function (postcode) {

        analytics.track('Postcode lookup', {
            postcode: postcode
        });

        return GeocoderQueries.geocodePostcode(postcode);
    },
    receiveCoordinates: function(latLng) {

        this.state['latLng'] = latLng;
        this.hasChanged();
    }
});