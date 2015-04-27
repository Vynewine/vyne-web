var WarehouseStore = Marty.createStore({
    id: 'WarehouseStore',
    handlers: {
        getByLocation: WarehouseConstants.GET_BY_LOCATION,
        setWarehouse: WarehouseConstants.SET_WAREHOUSE
    },
    getInitialState: function () {
        return {
            weDeliver: false
        };
    },
    weDeliver: function () {
        return this.state['weDeliver'];
    },
    getByLocation: function (lat, lng) {
        //return this.fetch({
        //    id: String(lat) + String(lng),
        //    locally: function () {
        //        return this.state[String(lat) + String(lng)];
        //    },
        //    remotely: function () {
        //        return WarehouseQueries.for(this).getWarehouseForLocation(lat, lng);
        //    }
        //});

        return WarehouseQueries.for(this).getWarehouseForLocation(lat, lng);
    },
    setWarehouse: function (res) {
        console.log(res);
        this.state['weDeliver'] = true;
        this.hasChanged();
    }
});