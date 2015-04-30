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
                    this.dispatch(CartConstants.SET_CART, res.body);
                    VyneRouter.transitionTo('choose-bottles');
                } else if (res.status === 404) {
                    this.dispatch(CartConstants.RESET_CART);
                    this.dispatch(ErrorConstants.SET_ERRORS, ["We're sorry byt your cart is empty please retry."]);
                } else {
                    this.dispatch(ErrorConstants.SET_ERRORS, res.status);
                }

            }).bind(this)
        ).catch(function (err) {
                this.dispatch(ErrorConstants.SET_ERRORS, err.message);
            }.bind(this));
    },
    initiate: function () {
        var cartId = CartCookieApi.getcartId();

        if (cartId) {
            CartHttpApi.for(this).show(cartId).then(
                (function (res) {
                    if (res.status === 200) {
                        this.dispatch(CartConstants.SET_CART, res.body);
                    } else {
                        this.dispatch(ErrorConstants.SET_ERRORS, res.status);
                    }

                }).bind(this)
            ).catch(function (err) {
                    this.dispatch(ErrorConstants.SET_ERRORS, err.message);
                }.bind(this));
        }
    }
});