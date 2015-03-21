var renderCart = function (wines) {

    if ($('body.shop.new').length) {

        wines = applyPromotions(wines);

        var promoInfo = JSON.parse($('#promotion').val());

        React.render(
            <Cart wines={wines} promoInfo={promoInfo} />,
            document.getElementById('cart')
        );

        PubSub.publish('cart-update', wines);
    }
};

var applyPromotions = function (wines) {

    var promoInfo = JSON.parse($('#promotion').val());

    if (promoInfo.free_bottle_category) {
        for (var i = 0; i < wines.length; ++i) {
            if (wines[i].category === promoInfo.free_bottle_category) {
                wines[i].promoPrice = 0;
                break;
            }
        }
    } else {
        for (var i = 0; i < wines.length; ++i) {
                wines[i].promoPrice = null;
        }
    }

    return wines;
};

var renderMiniCart = function (msg, data) {

    React.render(
        <MiniCart wines={data} />,
        document.getElementById('mini-cart')
    );

};

PubSub.subscribe('cart-update', renderMiniCart);

var Cart = React.createClass({
    getInitialState: function () {
        return {
            wines: this.props.wines ? this.props.wines : []
        }
    },
    componentWillReceiveProps: function (newProps) {
        if (newProps.wines.length) {
            this.setState({
                wines: applyPromotions(newProps.wines)
            });
        }
    },
    handleWinesChange: function (newWines) {

        this.setState({
            wines: newWines
        });

        if (!newWines.length) {
            resetEventsForEmptyCart();
            wineCount = 0;
        }

        // Update Rest of the app
        wines = newWines;
        $.cookie('wines', JSON.stringify(newWines));

        PubSub.publish('cart-update', newWines);

        if (newWines.length) {
            this.setState({
                wines: applyPromotions(newWines)
            });
        }
    },
    handleRemoveBottle: function (id) {

        this.state.wines.forEach(function (wine, index) {
            if (wine.id === id) {
                this.state.wines.splice(index, 1);
            }
        }.bind(this));

        this.state.wines.forEach(function (wine, index) {
            wine.id = index;
        }.bind(this));

        this.handleWinesChange(this.state.wines);

    },
    render: function () {

        var cartItems = [];
        this.state.wines.forEach(function (wine) {
            cartItems.push(<Cart.Item wine={wine} onBottleRemove={this.handleRemoveBottle} key={wine.id} />);
        }.bind(this));

        return (
            <div>
                <table className="order-table-cart">
                    <thead></thead>
                    <tbody>
                        <tr>
                            <th width="80%">Wine</th>
                            <th width="20%">Price</th>
                        </tr>
                        {cartItems}
                        <Cart.ManageBottles wines={this.state.wines} onWineChange={this.handleWinesChange} />
                        <Cart.Promotions promoInfo={this.props.promoInfo} />
                        <Cart.Totals wines={this.state.wines} promoInfo={this.props.promoInfo} />
                    </tbody>
                </table>
                <Cart.Checkout wines={this.state.wines} />
            </div>
        )
    }
});

Cart.Item = React.createClass({
    handleRemoveBottle: function (id, e) {
        e.preventDefault();
        this.props.onBottleRemove(id);
    },
    render: function () {

        var foods = [];

        if (this.props.wine.food.length) {

            this.props.wine.food.forEach(function (food, index) {
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

Cart.ManageBottles = React.createClass({
    handleAddTheSameBottle: function () {

        var wines = this.props.wines;
        var theSameWine = $.extend(true, {}, wines[0]);

        theSameWine.id = wines[0].id + 1;
        theSameWine.promoPrice = null;

        wines.push(theSameWine);

        this.props.onWineChange(wines);

        secondBottle = false;

        analytics.track('Review order', {
            action: 'Add same bottle'
        });
    },
    handleAddAnotherBottle: function () {

        secondBottle = true;

        orderSwiper.swipeTo(0, 500);

        analytics.track('Review order', {
            action: 'Add another bottle'
        });
    },
    handleAddBottle: function () {

        secondBottle = false;

        orderSwiper.swipeTo(0, 500);

        analytics.track('Review order', {
            action: 'Add a bottle'
        });
    },
    render: function () {

        var visibility = {display: 'table-row'};

        var addBottle = '';
        if (this.props.wines.length === 1) {
            addBottle = (
                <div>
                    <div>
                        <a className="btn btn__small add-same-bottle-link" onClick={this.handleAddTheSameBottle}>Add same bottle</a>
                    </div>
                    <div>
                        <span className="or">or</span>
                    </div>
                    <div>
                        <a className="btn btn__small add-bottle-link another-bottle" id="add-another-bottle" onClick={this.handleAddAnotherBottle}>Add another bottle</a>
                    </div>
                </div>
            )
        } else if (this.props.wines.length === 0) {
            addBottle = (
                <div>
                    <div>No bottles selected</div>

                    <a className="btn btn__small add-bottle-link another-bottle" onClick={this.handleAddBottle}>Add bottle</a>
                </div>
            )
        } else {
            visibility = {display: 'none'};
        }

        return (
            <tr className="add-bottle" style={visibility}>
                <td colSpan="2">
                {addBottle}
                </td>
            </tr>
        )
    }
});

Cart.Promotions = React.createClass({
    render: function () {

        if (!this.props.promoInfo || !this.props.promoInfo.title) {
            return false;
        }

        var title = '';
        var description = '';
        var errors = '';
        if (this.props.promoInfo.errors.length) {
            errors = (<div className="promotion-errors">{this.props.promoInfo.errors.join(',')}</div>)
        } else {
            title = (<div className="promotion-heading">
                <i className="fa fa-gift"></i>{' '}
                Promotion: {this.props.promoInfo.title}
            </div>);

            if (this.props.promoInfo.description !== '') {
                description = (<span className="promotion-description">{this.props.promoInfo.description}</span>);
            }
        }

        return (
            <tr className="promotion">
                <td colSpan="2" className="promotion-area">
                    {title}
                    {description}
                    {errors}
                </td>
            </tr>
        )
    }
});


Cart.Totals = React.createClass({
    render: function () {

        if (!this.props.wines.length) {
            return false;
        }

        var lowerDeliveryCost = 2.5;
        var higherDeliveryCost = 3.50;
        var totalMinimum = 0.00;
        var totalMaximum = 0.00;
        var deliveryCost = 0.00;
        var deliveryDisclaimer = '';

        this.props.wines.forEach(function (wine) {
            if(wine.promoPrice !== null) {
                totalMinimum += wine.promoPrice;
                totalMaximum += wine.promoPrice;
            } else {
                totalMinimum += parseFloat(wine.priceMin);
                totalMaximum += parseFloat(wine.priceMax);
            }

            if (wine.category == 1) {
                deliveryCost = higherDeliveryCost;
            } else {
                deliveryCost = lowerDeliveryCost;
            }
        });

        if (this.props.wines.length > 1) {
            deliveryCost = lowerDeliveryCost;
        }



        if(this.props.promoInfo.free_delivery) {
            deliveryCost = 0;
        }

        if (deliveryCost == lowerDeliveryCost) {
            deliveryDisclaimer = '(flat fee)';
        } else {
            if(deliveryCost === 0) {
                deliveryDisclaimer = '';
            } else {
                deliveryDisclaimer = '(wine under £15.00)';
            }

        }

        totalMinimum += deliveryCost;
        totalMaximum += deliveryCost;

        if(parseInt(totalMinimum + totalMaximum) === 0) {
            free = true;
        } else {
            free = false;
        }

        return (
            <tr className="total">
                <td colSpan="2">
                    <div>
                        Delivery
                        <span className="disclaimer" id="delivery-disclaimer"> {deliveryDisclaimer} </span>
                        £
                        <span className="price">{deliveryCost.toFixed(2)}</span>
                    </div>
                    <div className="cart-divider"></div>
                    <div>
                        Total
                        <span className="disclaimer"> (range) </span>
                        £
                        <span className="price">{totalMinimum.toFixed(2)}-{totalMaximum.toFixed(2)}</span>
                    </div>
                </td>
            </tr>

        )
    }
});

Cart.Checkout = React.createClass({
    handleCheckout: function (e) {
        e.preventDefault();
        orderSwiper.swipeNext();
    },
    render: function () {

        if (!this.props.wines.length) {
            return false;
        }

        return (
            <div className="btn-checkout">
                <a href="" id="checkout" onClick={this.handleCheckout} className="btn btn__full-width">Finalise Order</a>
            </div>
        )
    }
});

MiniCart = React.createClass({
    handleCartClick: function (e) {

        e.preventDefault();

        cleanupUnfinishedWines();
        resetEventsForCart();
        updateOrderSummary();

        orderSwiper.swipeTo(2, 500, false);

        analytics.track('Review order', {
            action: 'Cart link clicked',
            cart_count: this.props.wines.length
        });
    },
    render: function () {

        var countStyle = {display: 'none'};

        if (this.props.wines.length) {
            countStyle = {display: 'block'};
        }

        return (
            <a className="cart-link" href="" onClick={this.handleCartClick} style={countStyle}>
                <div className="mini-cart-image"></div>
                <span className="cart-count" >{this.props.wines.length}</span>
            </a>
        )
    }
});