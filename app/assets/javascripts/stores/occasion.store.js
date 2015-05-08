var OccasionStore = Marty.createStore({
    id: 'OccasionStore',
    getOccasions: function () {
        return occasions();
    },
    getWineTypes: function () {
        return wineTypes();
    }
});

var occasions = function () {
    return [
        {id: 1, name: "Solo"},
        {id: 2, name: "With Friends"},
        {id: 3, name: "Party"},
        {id: 4, name: "Date"},
        {id: 5, name: "Dining"},
        {id: 6, name: "Outdoors"},
        {id: 7, name: "Gift"}
    ]
};

var wineTypes = function () {
    return [
        {id: 1, name: "Bold Red"},
        {id: 2, name: "Medium Red"},
        {id: 3, name: "Light Red"},
        {id: 4, name: "Rosé"},
        {id: 5, name: "Rich White"},
        {id: 6, name: "Dry White"},
        {id: 7, name: "Sparkling"},
        {id: 8, name: "Sweet White"},
        {id: 10, name: "Fortified"}
    ]
};