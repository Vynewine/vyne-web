var WarehouseQueries = Marty.createQueries({
    id: 'WarehouseQueries',
    getWarehouseForLocation: function(lat, lng) {
        return WarehouseHttpApi.for(this).checkAvailability(lat, lng).then((function(res) {
                return this.dispatch(AppConstants.WAREHOUSES_GET_BY_LOCATION, res.body);
            }).bind(this));
    }
});