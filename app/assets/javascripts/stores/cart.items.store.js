var CartItemsStore = Marty.createStore({
    id: 'CartItemsStore',
    handlers: {
        setCartItem: CartItemsConstants.SET_CART_ITEM
    },
    getCartItem: function(id) {
        return this.state['cart_item_' + id]
    },
    setCartItem: function (res) {
        this.state['cart_item_' + res.data.id] = res.data;
        this.hasChanged();
    }
});