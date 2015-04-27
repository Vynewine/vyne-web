var WarehouseActionCreators = Marty.createActionCreators({
    id: 'WarehouseAction',
    getByLocation: function (lat, lng) {
        this.dispatch(WarehouseConstants.GET_BY_LOCATION, lat, lng);
    }
});