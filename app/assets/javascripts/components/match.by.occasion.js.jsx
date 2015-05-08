var MatchByOccasion = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    render: function () {
        var name = this.context.router.getCurrentPath();
        return (
            <div>
                Great occasion
                <Router.RouteHandler key={name} {...this.props}/>
            </div>
        );
    }
});

MatchByOccasion.Occasions = React.createClass({
    handleOccasionChoice: function (occasion) {
        VyneRouter.transitionTo('match-by-occasion-select-type', {occasionId: occasion.id});
    },
    render: function () {

        if (!this.props.occasions) {
            return false;
        }

        var occasions = [];

        this.props.occasions.map(function (occasion) {
            occasions.push(
                <button key={occasion.id} className="btn btn-primary"
                        onClick={this.handleOccasionChoice.bind(this, occasion)}>
                    {occasion.name}
                </button>
            );
        }.bind(this));


        return (
            <div>
                <div className="row">
                    {occasions}
                </div>
            </div>
        );
    }
});

MatchByOccasion.WineTypes = React.createClass({
    handleTypeSelection: function (wineType) {

        var cartItem = this.props.currentCartItem;

        cartItem.occasion_id = this.props.params.occasionId;
        cartItem.type_id = wineType.id;

        CartActionCreators.createOrUpdateItem(cartItem);

    },
    render: function () {

        if (!this.props.wineTypes) {
            return false;
        }

        var wineTypes = [];

        this.props.wineTypes.map(function (wineTpe) {
            wineTypes.push(
                <button key={wineTpe.id} className="btn btn-primary"
                        onClick={this.handleTypeSelection.bind(this, wineTpe)}>
                    {wineTpe.name}
                </button>
            );

        }.bind(this));

        return (
            <div>

                <div className="row">
                    {wineTypes}
                </div>
            </div>
        );
    }
});

var MatchByOccasionContainer = Marty.createContainer(MatchByOccasion, {
    listenTo: [OccasionStore, CartStore],
    fetch: {
        occasions: function () {
            return OccasionStore.getOccasions();
        },
        wineTypes: function () {
            return OccasionStore.getWineTypes();
        },
        currentCartItem: function() {
            return CartStore.getCurrentCartItem();
        }
    },
    pending: function () {
        return <div className='loading'>Loading...</div>;
    },
    failed: function (errors) {
        console.log(errors);
        return <div className='error'>Failed to load. {errors}</div>;
    }
});