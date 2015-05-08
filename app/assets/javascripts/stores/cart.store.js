var CartStore = Marty.createStore({
    id: 'CartStore',
    handlers: {
        setCart: CartConstants.SET_CART,
        resetCart: CartConstants.RESET_CART,
        setCurrentCartItem: CartConstants.SET_CURRENT_CART_ITEM
    },
    getInitialState: function () {

    },
    getCart: function () {
        return this.state['cart'];
    },
    getCartItems: function () {
        if (this.state['cart'] && this.state['cart'].cart_items) {
            return this.state['cart'].cart_items
        } else {
            return null;
        }
    },
    getCurrentCartItem: function () {
        return this.state['currentCartItem'];
    },
    cartIsFull: function () {

        if (this.state['cart'] && this.state['cart'].cart_items && this.state['cart'].cart_items.length >= 2) {
            return true;
        } else {
            return false;
        }
    },
    setCart: function (cart) {
        this.state['cart'] = cart;

        this.resetCurrentCartItem();

        this.hasChanged();
    },
    resetCart: function () {
        this.state['cart'] = null;
        CartCookieApi.resetCartId();
    },
    resetCurrentCartItem: function () {
        if(this.state['cart'] && !this.cartIsFull()) {
            this.state['currentCartItem'] = {
                category_id: null,
                specific_wine: null,
                occasion_id: null,
                type_id: null,
                food_items: []
            }
        }
    },
    setCurrentCartItem: function(cartItem) {
        this.state['currentCartItem'] = cartItem;
        this.hasChanged();
    }
});