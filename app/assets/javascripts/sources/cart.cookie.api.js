var CartCookieApi = Marty.createStateSource({
    type: 'cookie',
    id: 'CartCookieApi',
    getcartId: function () {
        return this.get('cart_id');
    },
    resetCartId: function() {
        this.expire('cart_id');
    }
});