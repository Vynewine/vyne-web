var CartItemsHttpApi = Marty.createStateSource({
    type: 'http',
    id: 'CartItemsHttpApi',
    baseUrl: '/api/v1/cart',
    create: function (params) {
        return this.post({
            url: '/',
            body: {
                postcode: params.postcode,
                warehouse_id: params.warehouseId,
                delivery_type: params.deliveryType,
                slot_date: params.slotDate,
                slot_from: params.slotFrom,
                slot_to: params.slotTo
            }
        });
    },
    update: function (params, cartId) {
        return this.put({
            url: '/' + cartId,
            body: {
                postcode: params.postcode,
                warehouse_id: params.warehouseId,
                delivery_type: params.deliveryType,
                slot_date: params.slotDate,
                slot_from: params.slotFrom,
                slot_to: params.slotTo
            }
        });
    }
});