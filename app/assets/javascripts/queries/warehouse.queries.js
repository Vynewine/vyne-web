var WarehouseQueries = Marty.createQueries({
    id: 'WarehouseQueries',
    getWarehouseForLocation: function(lat, lng) {
        return WarehouseHttpApi.for(this).checkAvailability(lat, lng).then((function(res) {
                return this.dispatch(WarehouseConstants.SET_WAREHOUSE, res.body);
            }).bind(this));
    }
});