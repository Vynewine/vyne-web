var ChooseBottles = React.createClass({
    componentDidMount: function () {
        if(!this.props.cart) {
            VyneRouter.transitionTo('/');
        }
    },
    chooseBottle: function (id, e) {
        e.preventDefault();

        CartActionCreators.createOrUpdateItem({
            categoryId: id,
            itemId: this.props.currentCartItemId
        });
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
            return CartStore.getCart()
        },
        currentCartItemId: function() {
            return CartStore.currentCartItemId()
        }
    }
});