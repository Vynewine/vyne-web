var renderCart = function (wines) {
    if ($('body.shop.new').length) {

        var promoInfo = JSON.parse($('#promotion').val());

        React.render(
            <Cart wines={wines} promoInfo={promoInfo} />,
            document.getElementById('cart')
        );
    }
};

var Cart = React.createClass({
    getInitialState: function () {
        return {
            wines: this.props.wines
        }
    },
    handleWinesChange: function (newWines) {

        console.log('sweet');

        this.setState({
            wines: newWines
        });

        // Update Rest of the app
        wines = newWines;
        $.cookie('wines', JSON.stringify(newWines));
    },
    handleRemoveBottle: function (id) {

        this.state.wines.forEach(function (wine, index) {
            if (wine.id === id) {
                this.state.wines.splice(index, 1);
            }
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
                React Cart Start
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
                        <Cart.Totals wines={this.state.wines} />
                    </tbody>
                </table>
                React Card End
            </div>
        )
    }
});

Cart.Item = React.createClass({
    handleRemoveBottle: function (id) {
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

        return (
            <tr className="order-bottle-cart" key={this.props.wine.id}>
                <td className="order-table-bottle wine-bottle">
                    <a
                        href="#"
                        className="delete-bottle"
                        onClick={this.handleRemoveBottle.bind(this, this.props.wine.id)}
                    >x</a>
                    <div className="wine-bottle"></div>
                    <span className="label">{this.props.wine.label}</span>
                    <span className="occasionName">{this.props.wine.occasionName}</span>
                    <span className="wineType">{this.props.wine.wineType.name}</span>
                    <ul className="food">{foods}</ul>
                </td>
                <td className="order-table-bottle-price">
                    <span className="price">£{parseInt(this.props.wine.priceMin)}-{parseInt(this.props.wine.priceMax)}</span>
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

        wines.push(theSameWine);

        this.props.onWineChange(wines);
    },
    handleAddAnotherBottle: function () {
        console.log('another bottle');
    },
    handleAddBottle: function() {

    },
    render: function () {

        var addBottle = '';
        if(this.props.wines.length === 1) {
            addBottle = (
                <div>
                    <div>
                        <a className="btn btn__small add-same-bottle-link" onClick={this.handleAddTheSameBottle}>Add same bottle</a>
                    </div>
                    <div>
                        <span className="or">or</span>
                    </div>
                    <div>
                        <a className="btn btn__small add-bottle-link another-bottle" onClick={this.handleAddAnotherBottle}>Add another bottle</a>
                    </div>
                </div>
            )
        } else if(this.props.wines.length === 0) {
            addBottle = (
                <div>
                    <div>No bottles selected</div>

                    <a className="btn btn__small add-bottle-link another-bottle" onClick={this.handleAddBottle}>Add bottle</a>
                </div>
            )
        } else {
            return false;
        }

        return (
            <tr className="add-bottle">
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
            totalMinimum += parseFloat(wine.priceMin);
            totalMaximum += parseFloat(wine.priceMax);
            if (wine.category == 1) {
                deliveryCost = higherDeliveryCost;
            } else {
                deliveryCost = lowerDeliveryCost;
            }
        });

        if (this.props.wines.length > 1) {
            deliveryCost = lowerDeliveryCost;
        }

        totalMinimum += deliveryCost;
        totalMaximum += deliveryCost;

        if (deliveryCost == lowerDeliveryCost) {
            deliveryDisclaimer = '(flat fee)';
        } else {
            deliveryDisclaimer = '(wine under £15.00)';
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