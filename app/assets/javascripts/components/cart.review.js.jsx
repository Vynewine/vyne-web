CartReview = React.createClass({
    handleCheckout: function(e) {
        e.preventDefault();
        VyneRouter.transitionTo('account');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">
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