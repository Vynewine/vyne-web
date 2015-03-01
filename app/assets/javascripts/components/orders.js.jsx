var OrderSummary = React.createClass({

    getInitialState: function () {
        return {}
    },
    getDefaultProps: function () {

    },
    render: function () {

        var deliveryTime = 'ASAP';

        if (this.props.order.order_schedule) {
            var deliveryFrom = moment.utc(this.props.order.order_schedule.from);
            var deliveryTo = moment.utc(this.props.order.order_schedule.to);
            deliveryTime = deliveryFrom.format('dddd MMMM Do') + ' between ' + deliveryFrom.format('h:mm a') + ' and ' + deliveryTo.format('h:mm a');
        }

        return (
            <div>
                <div className="row">
                    <div className="col-xs-12">
                        <h4 className="app-title order-heading">
                            Order details:
                        </h4>
                    </div>
                </div>

                <div className="row">
                    <div className="col-xs-12">
                        Order Id: {this.props.order.id},
                        Created: {moment.utc(this.props.order.created_at).format('dddd MMMM Do h:mm a')}
                    </div>
                </div>

                <div className="row">
                    <div className="col-xs-12">Delivery to: {this.props.order.address}
                    </div>
                </div>

                <div className="row">
                    <div className="col-xs-12">
                        When: {deliveryTime}
                    </div>
                </div>
            </div>
        );
    }
});

var WinePreferences = React.createClass({
    render: function () {

        var wines = [];
        if (this.props.orderItems.length) {
            this.props.orderItems.map(function (item) {
                wines.push(
                    <div className="row" key={item.id}>
                        <div className="col-xs-12">
                    {item.quantity}x - {item.category.name}&nbsp;
                            (£{parseFloat(item.category.price_min).toFixed(2)}
                            -{parseFloat(item.category.price_max).toFixed(2)})&nbsp;-&nbsp;
                        {item.preferences.join(', ')}
                        </div>
                    </div>
                );
            });
        }

        return (
            <div>
                <div className="row">
                    <div className="col-xs-12">
                        <h4 className="app-title order-heading">
                            Wine Pereference:
                        </h4>
                    </div>
                </div>
            {wines}
                <div className="order-divider"></div>

            </div>
        )
    }
});

var WineSelection = React.createClass({
    getInitialState: function () {
        return {
            expand: 'collapse',
            expandedId: 0
        }
    },
    showMoreWineInfo: function (item) {
        this.setState({
            expandedId: item.id
        });
    },
    showLessWineInfo: function (item) {
        this.setState({
            expandedId: 0
        });
    },
    render: function () {

        var linkStyle = {float: "right"};

        var wines = [];
        if (this.props.orderItems.length) {
            this.props.orderItems.map(function (item) {

                wines.push(
                    <div className="row" key={item.id}>
                        <div className="col-xs-10">
                            <WineInfo orderItem={item} expanded={this.state.expandedId == item.id} />
                        </div>
                        <div className="col-xs-2">
                            <button
                                href="#"
                                style={linkStyle}
                                onClick={this.state.expandedId == item.id ? this.showLessWineInfo.bind(this, item) : this.showMoreWineInfo.bind(this, item) }
                                className="btn btn-primary btn-xs"
                            >{this.state.expandedId == item.id ? '- less' : '+ more'}</button>
                        </div>
                    </div>
                );
            }.bind(this));
        }

        return (
            <div>
                <div className="row">
                    <div className="col-xs-12">
                        <h4 className="app-title order-heading">
                            Wine Selection:
                        </h4>
                    </div>
                </div>
            {wines}
                <div className="order-divider"></div>

            </div>
        )
    }
});

var WineInfo = React.createClass({
    render: function () {
        if (!this.props.orderItem.wine)
            return false;

        var orderItem = this.props.orderItem;
        var wine = this.props.orderItem.wine;

        var row = function (text, key) {
            return <div className="row animated fadeIn" key={key}>
                <div className="col-xs-12">
                    {text}
                </div>
            </div>
        };

        var detailsRow = function (description, text, key) {
            return row(
                <div>
                    <span>{description}:</span>
                &nbsp;
                    <span>{text}</span>
                </div>, key
            )
        };

        var wineDescription = [
            (row(orderItem.quantity + 'x - ' + wine.full_info + ' - £ ' + parseFloat(orderItem.price).toFixed(2), 1))
        ];

        if (this.props.orderItem.advisory_note) {
            wineDescription.push(
                detailsRow('Merchant Note', this.props.orderItem.advisory_note, 1.1)
            );
        }

        var detailsSection = '';
        var wineDetails = [];

        if (this.props.expanded) {

            wineDetails.push(
                detailsRow('Producer', wine.producer.name, 2)
            );

            if (wine.region.name) {
                wineDetails.push(
                    detailsRow('Region', wine.region.name, 3)
                );
            }

            if (wine.subregion.name) {
                wineDetails.push(
                    detailsRow('Subregion', wine.subregion.name, 4)
                );
            }

            if (wine.locale.name) {
                wineDetails.push(
                    detailsRow('Locale', wine.locale.name, 5)
                );
            }

            if (wine.appellation.name) {
                wineDetails.push(
                    detailsRow('Appellation', wine.appellation.name, 6)
                );
            }

            if (wine.type.name) {
                wineDetails.push(
                    detailsRow('Type', wine.type.name, 7)
                );
            }

            if (wine.composition) {
                wineDetails.push(
                    detailsRow('Composition', wine.composition, 8)
                );
            }

            detailsSection = (
                <div>
                    {wineDetails}
                </div>
            )
        }

        return (
            <div>
            {wineDescription}
            {detailsSection}
            </div>
        )
    }
});

var Totals = React.createClass({
    render: function () {

        var total = parseFloat(this.props.order.estimated_total_min_price).toFixed(2) + ' - ' + parseFloat(this.props.order.estimated_total_max_price).toFixed(2);

        if (this.props.order.advisory_completed_at) {
            total = parseFloat(this.props.order.total_price).toFixed(2)
        }

        return (
            <div>
                <div className="row">
                    <div className="col-xs-6 totals">
                        Delivery: £{parseFloat(this.props.order.delivery_price).toFixed(2)}
                    </div>
                    <div className="col-xs-6 text-right totals">
                        Total: £{total}
                    </div>
                </div>
            </div>
        )
    }
});

var AcceptOrder = React.createClass({
    getInitialState: function () {
        return {pendingAcceptance: false}
    },
    componentWillReceiveProps: function (props) {

        if (props.order.order_change_timeout_seconds > 0) {
            this.setState({
                pendingAcceptance: false
            });
        }

        if (!this.state.shouldExpand && props.expanded) {
            this.setState({shouldExpand: true});
        } else {
            this.setState({shouldExpand: false});
        }
    },
    accept: function () {
        $.get('/orders/' + this.props.order.id + '/accept', function (data) {
            if (data.success) {
                this.setState({
                    pendingAcceptance: true
                });

                setTimeout(function () {
                    this.props.onOrderChange(this.props.order.id);
                }.bind(this), 3000);

            }
        }.bind(this));
    },
    render: function () {

        if (this.props.order.order_change_timeout_seconds < 1) {
            return false;
        }

        var substitutionMessage = '';

        if (this.props.order.can_request_substitution) {
            substitutionMessage = 'You may request changes to the selection below.'
        }

        var buttonText = (
            <div>
                <i className="fa fa-check"></i>
            &nbsp;
                Accept Order
            </div>
        );

        if (this.state.pendingAcceptance) {
            buttonText = <div className="animated fadeId">
            &nbsp; Processing
                <span className="one">.</span>
                <span className="two">.</span>
                <span className="three">.</span>
                ​
            </div>
        }

        return (
            <div>
                <div className="row">
                    <div className="col-xs-12 text-center">
                        <div className="order-divider"></div>
                        <span>Please review your order.</span>
                    </div>
                </div>
                <div className="row">
                    <div className="col-xs-12 text-center">
                        <button
                            className="btn btn-primary col-xs-12"
                            onClick={this.accept}
                        >{buttonText}</button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-xs-12 text-center">
                        {substitutionMessage}
                    </div>
                </div>
            </div>
        )
    }
});

var ChangeOrder = React.createClass({
    render: function () {

        if (this.props.order.order_change_timeout_seconds < 1) {
            return false;
        }

        var requestSubstitutions, cancelOrder;

        if (this.props.order.can_request_substitution) {
            requestSubstitutions = (
                <div className="row">
                    <div className="col-xs-12 text-center order-change">
                        <a href={'/orders/' + this.props.order.id + '/substitution_request'} className="btn btn-gray">
                            <i className="fa fa-exchange"></i>
                        &nbsp;
                            Change wine choice
                        </a>
                    </div>
                </div>
            )
        }

        if (this.props.order.order_change_timeout_seconds > 0) {
            cancelOrder = (
                <div className="row">
                    <div className="col-xs-12 text-center order-change">
                        <a href={'/orders/' + this.props.order.id + '/cancellation_request'} className="btn btn-warning">
                            Cancel Order
                        </a>
                    </div>
                </div>
            )
        }

        return (
            <div>
                <div className="order-divider"></div>
                {requestSubstitutions}
                {cancelOrder}
            </div>
        )
    }
});

var SetIntervalMixin = {
    componentWillMount: function () {
        this.intervals = [];
    },
    setMixinInterval: function () {
        this.intervals.push(setInterval.apply(null, arguments));
    },
    clearMixinInterval: function () {
        this.intervals.map(clearInterval);
    },
    componentWillUnmount: function () {
        this.intervals.map(clearInterval);
    }
};

var OrderChangeCountDown = React.createClass({
    mixins: [SetIntervalMixin],
    getInitialState: function () {
        return {seconds: 0};
    },
    componentDidMount: function () {
        this.setMixinInterval(this.tick, 1000); // Call a method on the mixin
    },
    tick: function () {
        this.setState({seconds: this.state.seconds + 1});
    },
    render: function () {
        return (
            <p>
                React has been running for {this.state.seconds} seconds.
            </p>
        );
    }
});

var OrderTimer = React.createClass({

    mixins: [SetIntervalMixin],

    getInitialState: function () {
        return {
            minutes: 0,
            seconds: 0,
            minuteText: '00',
            secondText: '00'
        };
    },
    componentDidMount: function () {
        var seconds = this.props.order.order_change_timeout_seconds;

        if (seconds > 0) {
            var minutes = Math.floor(seconds / 60);

            this.setState({
                minutes: minutes,
                seconds: seconds - minutes * 60,
                minuteText: '00'
            });

            this.setMixinInterval(this.tick, 1000);
        }
    },
    tick: function () {

        if (this.state.seconds < 0) {
            if (this.state.minutes == 0) {
                this.clearMixinInterval();
                this.props.onOrderChange(this.props.order.id);
            } else {
                this.setState({
                    minutes: this.state.minutes - 1,
                    seconds: 59
                });

            }
        }
        if (this.state.minutes > 0) {
            this.setState({
                minuteText: this.state.minutes < 10 ? '0' + this.state.minutes : this.state.minutes
            });

        } else {
            this.setState({
                minuteText: '00'
            });
        }

        if (this.state.seconds < 0) {
            this.setState({
                secondText: '00'
            });
        } else {
            this.setState({
                secondText: this.state.seconds < 10 ? '0' + this.state.seconds : this.state.seconds
            });
        }

        this.setState({
            seconds: this.state.seconds - 1
        });
    },
    render: function () {

        if (this.props.order.order_change_timeout_seconds <= 0) {
            return false;
        }

        return (
            <div className="row">
                <div className="col-xs-12 text-center">
                    This order will be scheduled for delivery in: {this.state.minuteText}:{this.state.secondText}
                </div>
            </div>
        )
    }
});

var Now = React.createClass({
    getInitialState: function () {
        return {
            nowText: ''
        }
    },
    setText: function (text) {
        this.setState({
            nowText: text
        });
    },
    componentWillMount: function () {
        this.checkStatus(this.props.order.status.label);
    },
    componentWillReceiveProps: function (props) {
        this.checkStatus(props.order.status.label);
    },
    checkStatus: function (status) {
        var merchantName = '';

        if (this.props.order.warehouse && this.props.order.warehouse.title) {
            merchantName = this.props.order.warehouse.title;
        }

        switch (status) {
            case 'pending':
                this.setText('Thank you for ordering! We submitted your order to your local merchant:' + merchantName);
                break;
            case 'advised':
                if (props.order.order_change_timeout_seconds > 0) {
                    this.setText('Your wines has been selected by merchant. Please approve wine selection.');
                } else {
                    this.setText('Your wines has been selected by merchant.');
                }
                break;
            case 'packing':
            case 'pickup':
                this.setText('The courier is on the first leg of the journey: to the wine cellar. Check this page in 10-20 minutes to see if the bottle has been collected and on its way to you.');
                break;
            case 'in transit':
                break;
            case 'delivered':
                break;
            case 'payment failed':
                break;
            case 'created':
                break;
            default:
                break;
        }
    },
    render: function () {

        if (this.state.nowText === '') {
            return false
        }

        return (
            <div>
                <div className="row">
                    <div className="col-xs-12">
                        <h4 className="app-title order-heading">
                            Now:
                        </h4>
                    </div>
                </div>

                <div className="row">
                    <div className="col-xs-12">
                    {this.state.nowText}
                    </div>
                </div>
            </div>
        )


    }
});

var Next = React.createClass({
    getInitialState: function () {
        return {
            nextText: ''
        }
    },
    setText: function (text) {
        this.setState({
            nextText: text
        });
    },
    checkStatus: function (status) {
        switch (status) {
            case 'pending':
                this.setText('We will notify you when our sommelier chooses your wine based on the preferences provided');
                break;
            case 'advised':
            case 'packing':
            case 'pickup':
                this.setText('You\'ll see wine coming your way');
                break;
            case 'in transit':
                break;
            case 'delivered':
                break;
            case 'payment failed':
                break;
            case 'created':
                break;
            default:
                break;
        }
    },
    componentWillMount: function () {
        this.checkStatus(this.props.order.status.label);
    },
    componentWillReceiveProps: function (props) {
        this.checkStatus(props.order.status.label);
    },

    render: function () {

        if (this.state.nextText === '') {
            return false;
        }

        return (
            <div>
                <div className="row">
                    <div className="col-xs-12">
                        <h4 className="app-title order-heading">
                            Next:
                        </h4>
                    </div>
                </div>

                <div className="row">
                    <div className="col-xs-12">
                    {this.state.nextText}
                    </div>
                </div>
            </div>
        )


    }
});

var Map = React.createClass({
    render: function () {

        if(this.props.order.status.label !== 'in transit') {
            return false;
        }

        var mapStyle = {
            width:  '100%',
            height: '300px'
        };

        return (
            <div>
                {this.props.order.status.label}
                <div id="map" style={mapStyle}></div>
            </div>
        )
    }
});

/**
 * Top Level Controller View
 */
var OrderDetails = React.createClass({
    mixins: [SetIntervalMixin],
    getInitialState: function () {
        return {
            orderDetails: null
        };
    },
    componentWillMount: function () {
        this.loadData(orderId)
    },
    componentDidMount: function () {
        this.setMixinInterval(this.tick, 10000);
    },
    tick: function () {
        this.loadData(orderId);
    },
    loadData: function (orderId) {
        getOrderDetails(orderId, function (orderDetails) {
            this.setState({orderDetails: orderDetails});
        }.bind(this));
    },
    handleOrderStatusChange: function (orderId) {
        this.loadData(orderId);
    },
    render: function () {

        if (!this.state.orderDetails)
            return false;

        var wines = <WinePreferences
            orderItems={this.state.orderDetails.order.order_items}
        />;

        if (this.state.orderDetails.order.advisory_completed_at) {
            wines = <WineSelection
                orderItems={this.state.orderDetails.order.order_items}
            />;
        }

        return (
            <div>
                <div className="row order-section">
                    <div className="col-xs-12">
                        <Map
                            order={this.state.orderDetails.order}
                        />
                    </div>
                </div>
                <div className="row order-section">
                    <div className="col-sm-6 col-xs-12">

                {/**
                 * left
                 */}
                        <OrderSummary
                            order={this.state.orderDetails.order}
                        />

                        <AcceptOrder
                            order={this.state.orderDetails.order}
                            onOrderChange={this.handleOrderStatusChange}
                        />

                    {wines}

                        <Totals
                            order={this.state.orderDetails.order}
                        />

                        <ChangeOrder
                            order={this.state.orderDetails.order}
                        />

                        <OrderTimer
                            order={this.state.orderDetails.order}
                            onOrderChange={this.handleOrderStatusChange}
                        />

                        <OrderChangeCountDown />

                    </div>

                    <div className="col-sm-6 col-xs-12">

                {/**
                 * right
                 */}

                        <Now
                            order={this.state.orderDetails.order}
                        />

                        <Next
                            order={this.state.orderDetails.order}
                        />
                    </div>
                </div>
            </div>
        );
    }
});

var renderOrderDetails = function () {
    if ($('body.orders').length && typeof(orderId) != "undefined" && $('#order-details').length) {

        React.render(
            <OrderDetails />,
            document.getElementById('order-details')
        );
    }
};

var getOrderDetails = function (orderId, callback) {
    $.get('/orders/' + orderId + '/order_details',
        function (orderDetails) {
            callback(orderDetails);
        });
};

$(document).on('page:change page:load', renderOrderDetails);
