var WarehouseQueries = Marty.createQueries({
    id: 'WarehouseQueries',
    getWarehouseForLocation: function (latLng) {
        return WarehouseHttpApi.for(this).checkAvailability(latLng.lat, latLng.lng).then(
            (
                function (res) {

                    return this.dispatch(WarehouseConstants.SET_WAREHOUSE, res.body);
                }
            ).bind(this)
        )
            .catch(
            function (err) {
                this.dispatch(ErrorConstants.SET_ERRORS, err.message);
            }.bind(this));
    }
});