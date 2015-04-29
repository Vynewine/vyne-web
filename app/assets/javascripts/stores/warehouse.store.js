var WarehouseStore = Marty.createStore({
    id: 'WarehouseStore',
    handlers: {
        getByLocation: WarehouseConstants.GET_BY_LOCATION,
        setWarehouse: WarehouseConstants.SET_WAREHOUSE
    },
    warehouse: function () {
        return this.state['warehouse'];
    },
    weDeliver: function() {
          return this.state['weDeliver'];
    },
    liveDeliveryEnabled: function() {
        return this.state['liveDeliveryEnabled'];
    },
    nextOpenWarehouse: function() {
        return this.state['nextOpenWarehouse'];
    },
    deliverySlots: function() {
        return this.state['deliverySlots'];
    },
    daytimeSlotsAvailable: function() {
        return this.state['daytimeSlotsAvailable'];
    },
    getByLocation: function (latLng) {
        var id = String(latLng.lat) + String(latLng.lng);
        return this.fetch({
            id: id,
            locally: function () {
                if (this.hasAlreadyFetched(id)) {
                    return this.state['warehouse']
                }
            },
            remotely: function () {
                return WarehouseQueries.for(this).getWarehouseForLocation(latLng);
            }
        });
    },
    setWarehouse: function (res) {
        console.log(res);

        if (res.data.today_warehouse) {
            if (!res.data.today_warehouse.id) {
                this.state['warehouse'] = null;
                this.state['weDeliver'] = false;
                this.state['liveDeliveryEnabled'] = false;

            } else {
                this.state['warehouse'] = res.data.today_warehouse;
                this.state['weDeliver'] = true;
                this.state['liveDeliveryEnabled'] = res.data.today_warehouse.is_open;
                this.state['nextOpenWarehouse'] = res.data.next_open_warehouse;
                this.state['deliverySlots'] = res.data.delivery_slots;
                this.state['daytimeSlotsAvailable'] = res.data.daytime_slots_available;
            }
        }

        this.hasChanged();
    }
});