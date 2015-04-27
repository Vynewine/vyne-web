var WarehouseStore = Marty.createStore({
    id: 'WarehouseStore',
    handlers: {
        getByLocation: AppConstants.WAREHOUSES_GET_BY_LOCATION
    },
    getInitialState: function () {
        return {};
    },
    getByLocation: function (lat, lng) {
        return this.fetch({
            id: String(lat) + String(lng),
            locally: function () {
                return this.state[String(lat) + String(lng)];
            },
            remotely: function () {
                return WarehouseQueries.for(this).getWarehouseForLocation(lat, lng);
            }
        });
    }
});