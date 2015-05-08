var CartItemsHttpApi = Marty.createStateSource({
    type: 'http',
    id: 'CartItemsHttpApi',
    baseUrl: '/api/v1/cart',
    create: function (cartId, cartItem) {
        return this.post({
            url: '/' + cartId + '/create_item',
            body: cartItem
        });
    },
    update: function (cartId, params) {
        return this.post({
            url: '/' + cartId + '/update_item',
            body: {
                category_id: params.categoryId,
                item_id: params.itemId
            }
        });
    }
});