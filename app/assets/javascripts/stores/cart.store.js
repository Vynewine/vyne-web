var CartStore = Marty.createStore({
    id: 'CartStore',
    handlers: {
        setCart: CartConstants.SET_CART,
        resetCart: CartConstants.RESET_CART
    },
    getCart: function() {
        return this.state['cart'];
    },
    getCartItems: function() {

    },
    setCart: function (res) {
        this.state['cart'] = res.data;
        this.hasChanged();
    },
    resetCart: function() {
        this.state['cart'] = null;
        CartCookieApi.resetCartId();
    }
});