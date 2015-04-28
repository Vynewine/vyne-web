var AddressCookieApi = Marty.createStateSource({
    type: 'cookie',
    id: 'AddressCookieApi',
    getPostcode: function () {
        return this.get('postcode');
    },
    setPostcode: function (postcode) {
        this.set('postcode', postcode);
    },
    getLatLng: function () {
        return {lat: this.get('lat'), lng: this.get('lng')};
    },
    setLat: function (lat) {
        return this.set('lat', lat);
    },
    setLng: function (lng) {
        return this.set('lng', lng);
    },
    isValidPostcode() {
        return this.get('isValidPostcode');
    },
    setIsValidPostcode(valid) {
        return this.set('isValidPostcode', valid);
    }
});