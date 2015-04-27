var AddressActionCreators = Marty.createActionCreators({
    id: 'AddressActions',
    geocodePostcode: function (postcode) {
        this.dispatch(AppConstants.GEOCODE_POSTCODE, postcode);
    },
    validatePostcode: function(postcode) {
        this.dispatch(AppConstants.VALIDATE_POSTCODE, postcode);
    }
});