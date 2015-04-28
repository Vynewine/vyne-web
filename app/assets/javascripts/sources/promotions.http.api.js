var PromotionsHttpApi = Marty.createStateSource({
    type: 'http',
    id: 'PromotionsHttpApi',
    baseUrl: '/api/v1',
    getPromotion: function () {
        return this.get('/promotions/');
    }
});