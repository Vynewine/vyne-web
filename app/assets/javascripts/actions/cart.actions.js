var CartActionCreators = Marty.createActionCreators({
    id: 'CartActions',
    createOrUpdate: function (params) {

        var cartId = CartCookieApi.getcartId();
        var cartRequest;

        if (cartId) {
            cartRequest = CartHttpApi.for(this).update(params, cartId)
        } else {
            cartRequest = CartHttpApi.for(this).create(params)
        }

        return cartRequest.then(
            (function (res) {
                if (res.status === 200) {
                    return this.dispatch(CartConstants.SET_CART, res.body);
                } else if(res.status === 404) {
                    return this.dispatch(CartConstants.RESET_CART);
                } else {
                    this.dispatch(ErrorConstants.SET_ERRORS, res.status);
                }

            }).bind(this)
        ).catch(function (err) {
                this.dispatch(ErrorConstants.SET_ERRORS, err.message);
            }.bind(this));
    }
});