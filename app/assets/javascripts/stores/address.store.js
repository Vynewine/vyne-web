var AddressStore = Marty.createStore({
    id: 'AddressStore',
    handlers: {
        setPostcode: AddressConstants.SET_POSTCODE
    },
    getInitialState: function () {

        return {
            postcode: AddressCookieApi.getPostcode()
        };
    },
    getPostcode: function () {
        return this.state['postcode'];
    },
    getLatLng: function () {
        if (this.state['postcode'] !== '') {
            return this.state[this.state['postcode']];
        }
    },
    isValidPostcode: function () {
        return this.state['isValidPostcode'];
    },
    setPostcode: function (postcode, valid, latLng) {

        analytics.track('Postcode validation', {
            postcode: postcode,
            valid: valid
        });

        this.state['isValidPostcode'] = valid;
        this.state['postcode'] = postcode;
        AddressCookieApi.setPostcode(postcode);

        if(latLng) {
            this.state[postcode] = latLng;
        }

        this.hasChanged();
    }
});