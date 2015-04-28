var PromotionQueries = Marty.createQueries({
    id: 'PromotionQueries',
    getPromotion: function() {
        return PromotionsHttpApi.for(this).getPromotion().then((function(res) {
            return this.dispatch(PromotionConstants.SET_PROMOTION, res.body);
        }).bind(this));
    }
});