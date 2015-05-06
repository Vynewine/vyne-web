var MatchByFood = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    render: function () {
        var name = this.context.router.getCurrentPath();
        return (
            <div>
                Matching Food:
                <Router.RouteHandler key={name}/>
            </div>
        );
    }
});

MatchByFood.Category = React.createClass({
    handleCategorySelection: function (e) {
        var category = $(e.target).data('category');
        console.log(category);
        VyneRouter.transitionTo('match-by-food-type');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-xs-1" onClick={this.handleCategorySelection} data-category="meat">Meat</div>
                    <div className="col-xs-1" onClick={this.handleCategorySelection} data-category="fish">Fish</div>
                    <div className="col-xs-1" onClick={this.handleCategorySelection} data-category="vegetable">
                        Vegetable
                    </div>
                </div>
            </div>
        );
    }
});

MatchByFood.Type = React.createClass({
    handleTypeSelection: function (e) {
        VyneRouter.transitionTo('match-by-food-preparation');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-xs-1" onClick={this.handleTypeSelection}>Beef</div>
                    <div className="col-xs-1" onClick={this.handleTypeSelection}>Chicken</div>
                    <div className="col-xs-1" onClick={this.handleTypeSelection}>Lamb</div>
                </div>
            </div>
        );
    }
});

MatchByFood.Preparation = React.createClass({
    handlePreparationSelection: function (e) {
        VyneRouter.transitionTo('match-by-food-review');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-xs-1" onClick={this.handlePreparationSelection}>Grill</div>
                    <div className="col-xs-1" onClick={this.handlePreparationSelection}>BBQ</div>
                    <div className="col-xs-1" onClick={this.handlePreparationSelection}>Roasted</div>
                </div>
            </div>
        );
    }
});

MatchByFood.Review = React.createClass({
    handleAddMoreFoodOptions: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-food-type');
    },
    handleFoodPreferencesComplete: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('cart-review');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.handleAddMoreFoodOptions}
                            >Select more food preferences
                        </button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.handleFoodPreferencesComplete}
                            >Done
                        </button>
                    </div>
                </div>
            </div>
        );
    }
});