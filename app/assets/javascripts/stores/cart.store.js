var CartStore = Marty.createStore({
    id: 'CartStore',
    handlers: {
        setCart: CartConstants.SET_CART,
        resetCart: CartConstants.RESET_CART
    },
    getInitialState: function () {
        CartActionCreators.initiate();
    },
    getCart: function() {
        return this.state['cart'];
    },
    getCartItems: function() {

    },
    currentCartItemId: function() {
        return this.state['current_cart_item_id']
    },
    setCart: function (cart, cart_item) {
        this.state['cart'] = cart;
        if(cart_item) {
            this.state['current_cart_item_id'] = cart_item.id
        }
        this.hasChanged();
    },
    resetCart: function() {
        this.state['cart'] = null;
        CartCookieApi.resetCartId();
    }
});