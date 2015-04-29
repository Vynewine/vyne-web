var AddressActionCreators = Marty.createActionCreators({
    id: 'AddressActions',
    validatePostcode: function(postcode) {

        var validated = validatePostcode(postcode);

        var valid = false;

        if (validated) {

            valid = true;

            var geocoder = new google.maps.Geocoder();

            geocoder.geocode({'address': 'London+' + postcode + '+UK'}, function (results, status) {

                var latLng = {
                    lat: '',
                    lng: ''
                };

                if (status == google.maps.GeocoderStatus.OK) {
                    latLng.lat = results[0].geometry.location.lat();
                    latLng.lng = results[0].geometry.location.lng();
                }

                return this.dispatch(AddressConstants.SET_POSTCODE, postcode, valid, latLng);

            }.bind(this));

        } else {
            this.dispatch(AddressConstants.SET_POSTCODE, postcode, valid);
        }
    }
});