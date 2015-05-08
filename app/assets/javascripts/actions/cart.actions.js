var CartActionCreators = Marty.createActionCreators({
    id: 'CartActions',
    initiate: function () {
        var cartId = CartCookieApi.getcartId();

        if (cartId) {
            CartHttpApi.for(this).show(cartId).then(
                (function (res) {
                    if (res.status === 200) {
                        this.dispatch(CartConstants.SET_CART, res.body.data.cart);

                        if(res.body.data.cart.cart_items && res.body.data.cart.cart_items.length) {
                            VyneRouter.transitionTo('cart-review');
                        }

                    } else {
                        if (res.status === 404) {
                            CartCookieApi.resetCartId();
                            VyneRouter.transitionTo('/');
                        } else {
                            this.dispatch(ErrorConstants.SET_ERRORS, res.status);
                        }

                    }

                }).bind(this)
            ).catch(function (err) {
                    this.dispatch(ErrorConstants.SET_ERRORS, err.message);
                }.bind(this));
        } else {
            VyneRouter.transitionTo('/');
        }
    },
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
                    this.dispatch(CartConstants.SET_CART, res.body.data.cart);

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
    createOrUpdateItem: function (cartItem) {

        var cartId = CartCookieApi.getcartId();
        var cartItemId = cartItem.itemId;
        var cartRequest;

        if (cartItemId) {
            cartRequest = CartItemsHttpApi.update(cartId, cartItem)
        } else {
            cartRequest = CartItemsHttpApi.create(cartId, cartItem)
        }

        return cartRequest.then(function (res) {
            if (res.status === 200) {
                this.dispatch(CartConstants.SET_CART, res.body.data.cart);
                VyneRouter.transitionTo('cart-review');
            } else {
                this.dispatch(ErrorConstants.SET_ERRORS, res.body.errors ? res.body.errors : [res.status]);
            }
        }.bind(this))
            .catch(function (err) {
                this.dispatch(ErrorConstants.SET_ERRORS, err.message);
            }.bind(this));
    },
    updateCurrentCartItem: function(cartItem) {
        this.dispatch(CartConstants.SET_CURRENT_CART_ITEM, cartItem);
    }
});