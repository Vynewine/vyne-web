var WarehouseHttpApi = Marty.createStateSource({
    type: 'http',
    id: 'WarehouseHttpApi',
    baseUrl: '/api/v1',
    checkAvailability: function (lat, lng) {
        return this.get('/warehouses/?lat=' + lat + '&lng=' + lng);
    }
});