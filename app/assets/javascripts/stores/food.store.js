var FoodStore = Marty.createStore({
    id: 'FoodStore',
    getFoods: function () {
        return foods();
    },
    getPreparations: function () {
        return preparations();
    }
});

var foods = function () {
    return [
        {
            id: 1,
            name: "meat",
            types: [
                {id: 9, name: "beef", hasPreparation: true},
                {id: 10, name: "cured meat", hasPreparation: false},
                {id: 11, name: "pork", hasPreparation: true},
                {id: 12, name: "chicken", hasPreparation: true},
                {id: 45, name: "duck & game", hasPreparation: true},
                {id: 46, name: "lamb", hasPreparation: true}
            ]
        },
        {
            id: 2,
            name: "fish",
            types: [
                {id: 13, name: "lobster & shellfish", hasPreparation: true},
                {id: 14, name: "fish", hasPreparation: true},
                {id: 15, name: "mussels & oysters", hasPreparation: false}
            ]
        },
        {
            id: 3,
            name: "dairy",
            types: [
                {id: 16, name: "soft cheese & cream", hasPreparation: false},
                {id: 17, name: "pungent cheese", hasPreparation: false},
                {id: 18, name: "hard cheese", hasPreparation: false}
            ]
        },
        {
            id: 5,
            name: "vegetables & fungi",
            types: [
                {id: 24, name: "onion & garlic", hasPreparation: false},
                {id: 25, name: "green vegetables", hasPreparation: true},
                {id: 26, name: "root vegetables", hasPreparation: true},
                {id: 27, name: "tomato & pepper", hasPreparation: true},
                {id: 28, name: "mushroom", hasPreparation: false},
                {id: 29, name: "nuts & seeds", hasPreparation: false},
                {id: 30, name: "beans & peas", hasPreparation: false},
                {id: 40, name: "white potato", hasPreparation: true},
                {id: 41, name: "sweet potato", hasPreparation: true}
            ]

        },
        {
            id: 6,
            name: "herb & spice",
            types: [
                {id: 31, name: "red pepper & chilli", hasPreparation: false},
                {id: 32, name: "pepper", hasPreparation: false},
                {id: 33, name: "baking spices", hasPreparation: false},
                {id: 34, name: "curry & hot sauce", hasPreparation: false},
                {id: 35, name: "herbs", hasPreparation: false},
                {id: 36, name: "exotic & aromatic", hasPreparation: false}
            ]
        },
        {
            id: 7,
            name: "carbs",
            types: [
                {id: 37, name: "white bread", hasPreparation: false},
                {id: 38, name: "pasta", hasPreparation: false},
                {id: 39, name: "rice", hasPreparation: false}
            ]
        },
        {
            id: 8,
            name: "sweet",
            types: [
                {id: 42, name: "fruit & berries", hasPreparation: false},
                {id: 43, name: "chocolate & coffee", hasPreparation: false},
                {id: 44, name: "vanilla & caramel", hasPreparation: false}
            ]
        }
    ]
};

var preparations = function () {
    return [
        {id: 1, name: "grill & BBQ"},
        {id: 2, name: "roasted"},
        {id: 3, name: "fried & sautéed"},
        {id: 4, name: "smoke"},
        {id: 5, name: "poached & steamed"},
        {id: 6, name: "raw"}
    ]
};