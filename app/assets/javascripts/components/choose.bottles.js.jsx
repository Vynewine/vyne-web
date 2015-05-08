var ChooseBottles = React.createClass({
    componentWillMount: function () {
        if(!this.props.cart) {
            VyneRouter.transitionTo('/');
        }

        if(this.props.cartIsFull) {
            VyneRouter.transitionTo('cart-review');
        }
    },
    chooseBottle: function (id, e) {
        e.preventDefault();

        var cartItem = this.props.currentCartItem;

        cartItem.category_id = id;

        CartActionCreators.updateCurrentCartItem(cartItem);

        VyneRouter.transitionTo('match-by');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.chooseBottle.bind(this, 1)}
                            >House
                        </button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.chooseBottle.bind(this, 2)}
                            >Reserve
                        </button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.chooseBottle.bind(this, 3)}
                            >Fine
                        </button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.chooseBottle.bind(this, 4)}
                            >Cellar
                        </button>
                    </div>
                </div>
            </div>
        );
    }
});

var ChooseBottlesContainer = Marty.createContainer(ChooseBottles, {
    listenTo: CartStore,
    fetch: {
        cart: function() {
            return CartStore.getCart();
        },
        currentCartItem: function() {
            return CartStore.getCurrentCartItem();
        },
        cartIsFull: function() {
            return CartStore.cartIsFull();
        }
    }
});