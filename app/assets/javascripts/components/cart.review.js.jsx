CartReview = React.createClass({
    handleCheckout: function(e) {
        e.preventDefault();
        VyneRouter.transitionTo('account');
    },
    handleRemoveBottle: function (id) {

        //this.state.wines.forEach(function (wine, index) {
        //    if (wine.id === id) {
        //        this.state.wines.splice(index, 1);
        //    }
        //}.bind(this));
        //
        //this.state.wines.forEach(function (wine, index) {
        //    wine.id = index;
        //}.bind(this));
        //
        //this.handleWinesChange(this.state.wines);

    },
    render: function () {

        if(!this.props.cart) {
            return false;
        }

        var cartItems = [];

        //if(this.props.cart.cart_items) {
        //    this.props.cart.cart_items.forEach(function (item) {
        //        cartItems.push(<CartReview.Item item={item} onBottleRemove={this.handleRemoveBottle} key={item.id} />);
        //    }.bind(this));
        //}

        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">
                        {cartItems}

                        <button
                            className="btn btn-primary"
                            onClick={this.handleCheckout}
                            >Checkout
                        </button>
                        Cart:
                        {JSON.stringify(this.props.cart)}
                    </div>
                </div>
            </div>
        );
    }
});

CartReview.Item = React.createClass({
    handleRemoveBottle: function (id, e) {
        e.preventDefault();
        //this.props.onBottleRemove(id);
    },
    render: function () {

        var foods = [];

        if (this.props.item.food.length) {

            this.props.item.food.forEach(function (food, index) {
                var foodLabel = food.name;
                if (food.preparationName) {
                    foodLabel += ' (' + food.preparationName + ')'
                }
                foods.push((<li key={index}>{foodLabel}</li>));
            })
        }

        var price = '';

        if (this.props.wine.promoPrice === 0) {
            price = (
                <div>
                    <div className="price-div">
                        <span className="price">£{this.props.wine.promoPrice}</span>
                    </div>
                    <div>
                        <span className="price-old">£{parseInt(this.props.wine.priceMin)}-{parseInt(this.props.wine.priceMax)}</span>
                    </div>
                </div>
            );
        } else {
            price = (<span className="price">£{parseInt(this.props.wine.priceMin)}-{parseInt(this.props.wine.priceMax)}</span>);
        }

        return (
            <tr className="order-bottle-cart" key={this.props.wine.id}>
                <td className="order-table-bottle wine-bottle">
                    <a
                        href="#"
                        className="delete-bottle"
                        onClick={this.handleRemoveBottle.bind(this, this.props.wine.id)}
                        >x</a>
                    <div className="wine-bottle"></div>
                    <div>
                        <span className="label">{this.props.wine.label}</span>
                    </div>
                    <div>
                        <span className="occasionName">{this.props.wine.occasionName}</span>
                    </div>
                    <div>
                        <span className="occasionName">{this.props.wine.specificWine}</span>
                    </div>
                    <div>
                        <span className="wineType">{this.props.wine.wineType.name}</span>
                    </div>
                    <ul className="food">{foods}</ul>
                </td>
                <td className="order-table-bottle-price">
                    {price}
                </td>
            </tr>
        )
    }
});

var CartReviewContainer = Marty.createContainer(CartReview, {
    listenTo: [CartStore],
    fetch: {
        cart: function() {
            return CartStore.getCart();
        }
    },
    pending: function() {
        return <div className='loading'>Loading...</div>;
    },
    failed: function(errors) {
        console.log(errors)
        return <div className='error'>Failed to load. {errors}</div>;
    }
});