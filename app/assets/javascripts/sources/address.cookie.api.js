var AddressCookieApi = Marty.createStateSource({
    type: 'cookie',
    id: 'AddressCookieApi',
    getPostcode: function () {
        return this.get('postcode');
    },
    setPostcode: function (postcode) {
        this.set('postcode', postcode);
    }
});