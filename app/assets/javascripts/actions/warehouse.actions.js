var WarehouseActionCreators = Marty.createActionCreators({
    id: 'WarehouseAction',
    getByLocation: function (latLng) {
        this.dispatch(WarehouseConstants.GET_BY_LOCATION, latLng);
    }
});