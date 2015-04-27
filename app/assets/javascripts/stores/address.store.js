var AddressStore = Marty.createStore({
    id: 'AddressStore',
    handlers: {
        geocodePostcode: AddressConstants.GEOCODE_POSTCODE,
        validatePostcode: AddressConstants.VALIDATE_POSTCODE,
        receiveCoordinates: AddressConstants.RECEIVE_COORDINATES
    },
    getInitialState: function () {

        return {
            isValidPostcode: false,
            postcode: AddressCookieApi.getPostcode(),
            lat: AddressCookieApi.getLat(),
            lng: AddressCookieApi.getLng()
        };
    },
    getPostcode: function () {
        return this.state['postcode'];
    },
    getLat: function () {
        return this.state['lat'];
    },
    getLng: function () {
        return this.state['lng'];
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

            analytics.track('Postcode validation', {
                postcode: postcode,
                valid: true
            });
        } else {
            this.state['isValidPostcode'] = false;
            this.state['postcode'] = '';
            AddressCookieApi.setPostcode('');

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

        this.state['lat'] = latLng.lat;
        this.state['lng'] = latLng.lng;

        this.hasChanged();
    }
});