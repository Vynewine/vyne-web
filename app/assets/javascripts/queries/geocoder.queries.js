var GeocoderQueries = Marty.createQueries({
    id: 'GeocoderQueries',
    geocodePostcode: function (postcode) {

        var geocoder = new google.maps.Geocoder();

        return geocoder.geocode({'address': 'London+' + postcode + '+UK'}, function (results, status) {

            var latLng = {
                lat: '',
                lng: ''
            };

            if (status == google.maps.GeocoderStatus.OK) {
                latLng.lat = results[0].geometry.location.lat();
                latLng.lng = results[0].geometry.location.lng();
            }

            AddressCookieApi.setLat(latLng.lat);
            AddressCookieApi.setLng(latLng.lng);

            this.dispatch(AppConstants.RECEIVE_COORDINATES, latLng);

        }.bind(this));
    }
});