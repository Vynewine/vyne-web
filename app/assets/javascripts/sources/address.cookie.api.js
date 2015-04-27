var AddressCookieApi = Marty.createStateSource({
    type: 'cookie',
    id: 'AddressCookieApi',
    getPostcode: function () {
        return this.get('postcode');
    },
    setPostcode: function (postcode) {
        this.set('postcode', postcode);
    },
    getLat: function () {
        return this.get('lat');
    },
    setLat: function (lat) {
        return this.set('lat', lat);
    },
    getLng: function () {
        return this.get('lng');
    },
    setLng: function (lng) {
        return this.set('lng', lng);
    }
});