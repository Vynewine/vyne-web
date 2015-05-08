var MatchBy = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    componentWillMount: function() {
        // If not editing existing cart item but cart is not empty redirect to cart review.
        if(!this.props.currentCartItem && this.props.cartItems) {
            VyneRouter.transitionTo('cart-review');
        }
        // If cart is empty but exists redirect back to choose a bottle.
        else if(!this.props.cartItems && this.props.cart) {
            VyneRouter.transitionTo('choose-bottles');
        }
        // If cart doesn't exist redirect to the beginning (check postcode or whatever is at the beginning in the future.)
        else if (!this.props.cart) {
            VyneRouter.transitionTo('check-postcode');
        }
    },
    render: function () {
        var name = this.context.router.getCurrentPath();
        return (
            <div>
                <Router.RouteHandler key={name} {...this.props}/>
            </div>
        );
    }
});

MatchBy.Options = React.createClass({
    handleMatchByFood: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-food');
    },
    handleMatchByOccasion: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-occasion');
    },
    handleMatchBySpecificWine: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-specific-wine');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div>
                        <div className="row">
                            <div className="col-sm-12">
                                <button
                                    className="btn btn-primary"
                                    onClick={this.handleMatchByFood}
                                    >Food
                                </button>
                            </div>
                        </div>
                        <div className="row">
                            <div className="col-sm-12">
                                <button
                                    className="btn btn-primary"
                                    onClick={this.handleMatchByOccasion}
                                    >Occasion
                                </button>
                            </div>
                        </div>
                        <div className="row">
                            <div className="col-sm-12">
                                <button
                                    className="btn btn-primary"
                                    onClick={this.handleMatchBySpecificWine}
                                    >Specific Wine
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
});

var MatchByContainer = Marty.createContainer(MatchBy, {
    listenTo: [CartStore],
    fetch: {
        currentCartItem: function () {
            return CartStore.getCurrentCartItem();
        },
        cartItems: function() {
            return CartStore.getCartItems();
        },
        cart: function() {
            return CartStore.getCart();
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