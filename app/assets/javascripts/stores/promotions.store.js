var PromotionStore = Marty.createStore({
    id: 'PromotionStore',
    handlers: {
        getPromotion: PromotionConstants.GET_PROMOTION,
        setPromotion: PromotionConstants.SET_PROMOTION
    },
    getInitialState: function () {
        return {
            weDeliver: false
        };
    },
    getPromotion: function () {
        return PromotionQueries.for(this).getPromotion();
    },
    setPromotion: function (res) {
        this.session['promotion'] = res.data;
        this.hasChanged();
    }
});