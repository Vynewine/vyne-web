var MatchByFood = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    render: function () {
        var name = this.context.router.getCurrentPath();
        return (
            <div>
                Matching Food:
                <Router.RouteHandler key={name} {...this.props}/>
            </div>
        );
    }
});

MatchByFood.Category = React.createClass({
    handleCategorySelection: function (categoryId) {
        VyneRouter.transitionTo('match-by-food-type', {id: categoryId});
    },
    render: function () {

        var foods = [];

        this.props.foods.map(function (food) {
            foods.push(
                <button key={food.id} className="btn btn-primary"
                        onClick={this.handleCategorySelection.bind(this, food.id)}>
                    {food.name}
                </button>
            );
        }.bind(this));

        return (
            <div>
                <div className="row">
                    {foods}
                </div>
            </div>
        );
    }
});

MatchByFood.Type = React.createClass({
    componentWillMount: function () {

        if (this.props.params && this.props.params.id) {
            this.setState({
                foodCategoryId: this.props.params.id
            });
        }

        if (this.props.foods) {

            var foodTypes = [];

            this.props.foods.map(function (food) {
                if (food.id.toString() === this.props.params.id) {
                    foodTypes = food.types;
                }
            }.bind(this));

            this.setState({
                foodTypes: foodTypes
            })
        }
    },
    handleTypeSelection: function (type) {

        if(type.hasPreparation) {
            VyneRouter.transitionTo('match-by-food-preparation');
        } else {
            VyneRouter.transitionTo('match-by-food-review');
        }
    },

    render: function () {

        if (!this.state.foodTypes) {
            return false;
        }

        var foodTypes = [];

        this.state.foodTypes.map(function (type) {
            foodTypes.push(
                <button key={type.id} className="btn btn-primary"
                        onClick={this.handleTypeSelection.bind(this, type)}>
                    {type.name}
                </button>
            );
        }.bind(this));

        return (
            <div>
                <div className="row">
                    {foodTypes}
                </div>
            </div>
        );
    }
});

MatchByFood.Preparation = React.createClass({
    handlePreparationSelection: function (preparation) {
        console.log(preparation);
        VyneRouter.transitionTo('match-by-food-review');
    },
    render: function () {

        var preparationTypes = [];

        this.props.preparations.map(function(preparation){
            preparationTypes.push(
                <button key={preparation.id} className="btn btn-primary"
                        onClick={this.handlePreparationSelection.bind(this, preparation)}>
                    {preparation.name}
                </button>
            );
        }.bind(this));

        return (
            <div>
                <div className="row">
                    {preparationTypes}
                </div>
            </div>
        );
    }
});

MatchByFood.Review = React.createClass({
    handleAddMoreFoodOptions: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-food');
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

var MatchByFoodContainer = Marty.createContainer(MatchByFood, {
    listenTo: [FoodStore],
    fetch: {
        foods: function () {
            return FoodStore.getFoods();
        },
        preparations: function () {
            return FoodStore.getPreparations();
        }
    },
    pending: function () {
        return <div className='loading'>Loading...</div>;
    },
    failed: function (errors) {
        console.log(errors)
        return <div className='error'>Failed to load. {errors}</div>;
    }
});