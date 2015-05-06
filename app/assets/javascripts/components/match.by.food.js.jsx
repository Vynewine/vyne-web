var Router = ReactRouter;
var Link = Router.Link;


var MatchByFood = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    render: function() {
        var name = this.context.router.getCurrentPath();
        return (
            <div>
                <Router.RouteHandler key={name}/>
            </div>
        );
    }
});

MatchByFood.Category = React.createClass({
    handleCategorySelection: function(e) {
        var category = $(e.target).data('value');
        console.log(category);
        VyneRouter.transitionTo('match-by-food-type');
    },
    render: function() {
        return (
            <div>
                <div className="row">
                    <div className="col-xs-1" onClick={this.handleCategorySelection} data-category="meat">Meat</div>
                    <div className="col-xs-1" onClick={this.handleCategorySelection} data-category="fish">Fish</div>
                    <div className="col-xs-1" onClick={this.handleCategorySelection} data-category="vegetable">Vegetable</div>
                </div>
            </div>
        );
    }
});

MatchByFood.Type = React.createClass({
    render: function() {
        return (
            <div>
                <div className="row">
                    <div className="col-xs-1">Beef</div>
                    <div className="col-xs-1">Chicken</div>
                    <div className="col-xs-1">Lamb</div>
                </div>
            </div>
        );
    }
});

MatchByFood.Preparation = React.createClass({
    render: function() {
        return (
            <div>
                <div className="row">
                    <div className="col-xs-1">Grill</div>
                    <div className="col-xs-1">BBQ</div>
                    <div className="col-xs-1">Roasted</div>
                </div>
            </div>
        );
    }
});