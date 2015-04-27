var AddressActionCreators = Marty.createActionCreators({
    id: 'AddressActions',
    geocodePostcode: function (postcode) {
        this.dispatch(AddressConstants.GEOCODE_POSTCODE, postcode);
    },
    validatePostcode: function(postcode) {
        this.dispatch(AddressConstants.VALIDATE_POSTCODE, postcode);
    }
});