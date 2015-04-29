var PromotionStore = Marty.createStore({
    id: 'PromotionStore',
    handlers: {
        getPromotion: PromotionConstants.GET_PROMOTION,
        setPromotion: PromotionConstants.SET_PROMOTION
    },
    getPromotion: function () {
        return this.fetch({
            id: 'promotion',
            locally: function () {
                if (this.hasAlreadyFetched('promotion')) {
                    return this.state['promotion']
                }
            },
            remotely: function () {
                return PromotionQueries.for(this).getPromotion();
            }
        });
    },
    setPromotion: function (res) {
        this.state['promotion'] = res.data;
        this.hasChanged();
    }
});