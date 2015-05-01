var CartItemsActionCreators = Marty.createActionCreators({
    id: 'CartItemsActionCreators',
    addItem: function (params) {

        var cartId = CartCookieApi.getcartId();

        CartItemsHttpApi.create(cartId, params)
            .then(function (res) {
                if (res.status === 200) {
                    this.dispatch(CartConstants.SET_CART, res.body);
                } else {
                    this.dispatch(ErrorConstants.SET_ERRORS, res.status);
                }
            }.bind(this))
            .catch(function (err) {
                this.dispatch(ErrorConstants.SET_ERRORS, err.message);
            }.bind(this));
    },
    updateItem: function (params) {
        var cartId = CartCookieApi.getcartId();
    }
});