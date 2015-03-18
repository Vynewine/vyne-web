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

        var sections = [];

        var section = function (description, text, key) {
            sections.push(
                <div className="row" key = {key}>
                    <div className="col-xs-12">
                        <span className="section-description">{description}:</span> {text}
                    </div>
                </div>
            );
        };

        section('Order Id', this.props.order.id, 1);
        section('Created', moment.utc(this.props.order.created_at).format('dddd MMMM Do h:mm a'), 2);

        if (this.props.order.status && this.props.order.warehouse && this.props.order.address) {
            if (this.props.order.status.label == 'cancelled') {
                section('Status', 'This order has been cancelled.', 3);
                section('Cancellation Reason', this.props.order.cancellation_note, 4);
            } else {
                section('Delivery to', this.props.order.address.full, 3);
                section('When', deliveryTime, 4);
                section('Merchant', this.props.order.warehouse.title, 5);
                section('Status', this.props.order.status.label, 6);
            }
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
                {sections}
            </div>
        );
    }
});

var WinePreferences = React.createClass({
    render: function () {

        var preferences = [];
        var addPreference = function (description, text, key) {
            preferences.push(
                (
                    <div className="row" key={key}>
                        <div className="col-xs-12">
                            <span className="section-description">{description}:</span> {text}
                        </div>
                    </div>
                )
            )
        };

        var promotion = '';
        var addPromotion = function (description) {
            promotion = (
                <div>
                    <div className="order-divider"></div>
                    <div className="row">
                        <div className="col-xs-12">
                            <span className="section-promotion">
                                <i className="fa fa-gift"></i>{' '}
                                Promotion: {description}</span>
                        </div>
                    </div>
                </div>
            )
        };

        if (this.props.orderItems.length) {

            var wines = this.props.orderItems.filter(function (item) {
                return !item.user_promotion;
            });

            var promoWines = this.props.orderItems.filter(function (item, index) {
                return item.user_promotion;
            });

            wines.forEach(function (item, index) {

                if (index === 1) {
                    preferences.push((<div className="order-divider" key="break"></div>));
                }


                if (item.category) {
                    addPreference('Category', item.category.name +
                    ' (£' + parseFloat(item.category.price_min).toFixed(2) +
                    '-' + parseFloat(item.category.price_max).toFixed(2) + ')', item.id + 'cat');
                }

                addPreference('Preferences', item.preferences.join(', '), item.id + 'pref');

            });

            promoWines.forEach(function (item) {
                addPromotion(item.user_promotion.title);
            });
        }

        return (
            <div>
                <div className="row">
                    <div className="col-xs-12">
                        <h4 className="app-title order-heading">
                            Your Wine Pereferences:
                        </h4>
                    </div>
                </div>
                {preferences}
                {promotion}
                <div className="order-divider"></div>

            </div>
        )
    }
});

var WineSelection = React.createClass({
    render: function () {

        var wines = [];
        if (this.props.orderItems.length) {
            this.props.orderItems.map(function (item, index) {

                if (index > 0) {
                    wines.push(<div className="order-divider" key={'divider-' + index}></div>);
                }

                wines.push(
                    <div className="row" key={item.id}>
                        <div className="col-xs-12">
                            <WineInfo orderItem={item} />
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
    getInitialState: function () {
        return {
            expanded: false
        }
    },
    showLessWineInfo: function () {
        this.setState({
            expanded: false
        });
    },
    showMoreWineInfo: function () {
        this.setState({
            expanded: true
        });
    },
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
                    <span className="section-description">{description}:</span>
                &nbsp;
                    <span>{text}</span>
                </div>, key
            )
        };

        var wineDescription = [
            detailsRow('Bottle Preferences', orderItem.preferences.join(', '), 1),
            detailsRow('Wine Selection', orderItem.quantity + 'x - ' + wine.full_info, 2),
            detailsRow('Price', '£' + parseFloat(orderItem.price).toFixed(2), 3)
        ];

        if (this.props.orderItem.advisory_note) {
            wineDescription.push(
                detailsRow('Merchant Note', this.props.orderItem.advisory_note, 1.1)
            );
        }

        var detailsSection = '';
        var wineDetails = [];
        var buttonText = '';

        if (this.state.expanded) {

            buttonText = '-less';

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
        } else {
            buttonText = '+more';
        }

        return (
            <div>
            {wineDescription}
            {detailsSection}
                <button
                    className="btn btn-primary btn-xs"
                    onClick={this.state.expanded ? this.showLessWineInfo : this.showMoreWineInfo }
                >{buttonText}</button>
            </div>
        )
    }
});

var Totals = React.createClass({
    render: function () {

        var total = parseFloat(this.props.order.estimated_total_min_price).toFixed(2) + ' - ' + parseFloat(this.props.order.estimated_total_max_price).toFixed(2);

        if (this.props.order.advisory_completed_at && this.props.order.status.label !== 'cancelled') {
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
    componentWillReceiveProps: function (props) {
        if (props.order.status) {
            if (props.order.status.label !== 'advised') {
                this.setState({
                    pendingAcceptance: false
                });
            }
        }
    },
    render: function () {

        if (this.props.order.order_change_timeout_seconds < 1 || justCancelled) {
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
                Confirm Selection
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

        if (this.props.order.order_change_timeout_seconds < 1 || justCancelled) {
            return false;
        }

        var requestSubstitutions, cancelOrder;

        if (this.props.order.can_request_substitution) {
            requestSubstitutions = (
                <div className="row">
                    <div className="col-xs-12 text-center order-change">
                        <a href={'/orders/' + this.props.order.id + '/substitution_request'} className="btn btn-warning">
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
                        <a href={'/orders/' + this.props.order.id + '/cancellation_request'} className="btn btn-gray">
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
            secondText: '00',
            initialized: false
        };
    },
    initialize: function (seconds) {
        if (seconds > 0 && !this.state.initialized) {

            var minutes = Math.floor(seconds / 60);

            this.setState({
                minutes: minutes,
                seconds: seconds - minutes * 60,
                minuteText: '00',
                initialized: true
            });

            this.setMixinInterval(this.tick, 1000);
        } else if (seconds <= 0 && this.state.initialized) {
            this.clearMixinInterval();
            this.setState({
                initialized: false
            });
        }
    },
    componentDidMount: function () {
        this.initialize(this.props.order.order_change_timeout_seconds);
    },
    componentWillReceiveProps: function (props) {
        this.initialize(props.order.order_change_timeout_seconds);
    },
    componentWillUnmount: function () {
        this.setState({
            initialized: false
        });
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

var Done = React.createClass({
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
        if (this.props.order.status) {
            this.checkStatus(this.props.order.status.label);
        }
    },
    componentWillReceiveProps: function (props) {
        if (props.order.status) {
            this.checkStatus(props.order.status.label);
        }
    },
    checkStatus: function (status) {
        var merchantName = '';

        if (this.props.order.warehouse && this.props.order.warehouse.title) {
            merchantName = this.props.order.warehouse.title;
        }

        //
        //Your order has been delivered.
        //<p>If you have any problems, get in touch via <br/><a href="https://vyne.zendesk.com/hc">Vyne Helpdesk</a>
        switch (status) {
            case 'created':
            case 'pending':
                this.setText('Thank you for ordering! We submitted your order to your local merchant: ' + merchantName + '.');
                break;
            case 'advised':
                this.setText('');
                break;
            case 'packing':
            case 'pickup':
                this.setText('');
                break;
            case 'in transit':
                this.setText('');
                break;
            case 'delivered':
                this.setText('');
                break;
            case 'payment failed':
                this.setText('Payment for your order failed. Please contact Vyne at: 020 3355 4338');
                break;
            default:
                this.setText('');
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
                    <div className="col-xs-12 text-center">
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
            case 'created':
            case 'pending':
                this.setText(
                    (
                        <div>
                            <p>We will notify you once the merchant's sommelier chooses your wine,
                                based on the preferences you provided.</p>
                            <p>You will be able to review their selection before delivery.</p>
                        </div>
                    )
                );
                break;
            case 'advised':
                this.setText('You can track the delivery of your wine.');
                break;
            case 'packing':
            case 'pickup':
                this.setText(
                    (
                        <div>
                            <p>The courier is on the first leg of the journey:
                                <br/>
                                to the wine cellar.</p>
                            <p>We'll send you a text very shortly, when the courier is on the way to your address.</p>
                            <p>Click the link in the text, or remain on this page, to track the courier's progress live</p>
                        </div>
                    )
                );
                break;
            case 'in transit':
                this.setText('Your wine is on it\'s way! Please make sure to be present at: ' +
                this.props.order.address.postcode + '.');
                break;
            case 'delivered':
            case 'payment failed':
                this.setText('');
                break;
            default:
                this.setText('');
                break;
        }
    },
    componentWillMount: function () {
        if (this.props.order.status) {
            this.checkStatus(this.props.order.status.label);
        }
    },
    componentWillReceiveProps: function (props) {
        if (props.order.status) {
            this.checkStatus(props.order.status.label);
        }
    },

    render: function () {

        if (this.state.nextText === '') {
            return false;
        }

        return (
            <div className="">
                <div className="row">
                    <div className="col-xs-12">

                    </div>
                </div>

                <div className="row ">
                    <div className="col-xs-12 ">
                        <div className="order-next text-center">

                            <p className="app-title">
                                Next Step
                            </p>
                            {this.state.nextText}
                        </div>

                    </div>
                </div>
            </div>
        )


    }
});

var PaymentInfo = React.createClass({
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-xs-12">
                        <h4 className="app-title order-heading">
                            Payment Method:
                        </h4>
                    </div>
                </div>

                <div className="row">
                    <div className="col-xs-12">
                    {this.props.order.payment ? this.props.order.payment.brand == 3 ?
                    '**** ****** ' + this.props.order.payment.number :
                    '**** **** **** ' + this.props.order.payment.number : ''}
                    </div>
                </div>
            </div>
        )
    }
});

var map;
var wineMarker;

var Map = React.createClass({
    getInitialState: function () {
        return {
            wineMarker: null
        }
    },
    getCourierLocation: function () {
        $.get('/delivery/get_courier_location?id=' + this.props.order.id, function (data) {

            if (!wineMarker) {
                var bottleIcon = L.icon({
                    iconUrl: '/wine-bottle.png',
                    iconRetinaUrl: '/wine-bottle@2x.png',
                    iconSize: [32, 32]
                });

                wineMarker = L.marker([data.data.lat, data.data.lng], {icon: bottleIcon}).addTo(map);

            } else {

                wineMarker.setLatLng(L.latLng(
                        data.data.lat,
                        data.data.lng)
                );
            }
        });
    },
    initialize: function () {

        map = L.map('map', {zoomControl: false, scrollWheelZoom: false});

        map.addControl(L.control.zoom({position: 'topright'}));

        var gl = new L.Google('ROAD');

        map.addLayer(gl);

        var warehouseIcon = L.icon({
            iconUrl: '/winebar.png',
            iconSize: [32, 32]
        });

        L.marker([
            this.props.order.warehouse.address.latitude,
            this.props.order.warehouse.address.longitude
        ], {icon: warehouseIcon}).addTo(map);

        var homeIcon = L.icon({
            iconUrl: '/home.png',
            iconSize: [32, 32]
        });

        L.marker([
            this.props.order.address.latitude,
            this.props.order.address.longitude
        ], {icon: homeIcon}).addTo(map);

        var directionsService = new google.maps.DirectionsService();

        var request = {
            origin: new google.maps.LatLng(this.props.order.warehouse.address.latitude, this.props.order.warehouse.address.longitude),
            destination: new google.maps.LatLng(this.props.order.address.latitude, this.props.order.address.longitude),
            travelMode: google.maps.TravelMode.BICYCLING
        };

        directionsService.route(request, function (result) {
            if (result && result.routes && result.routes.length) {

                var line_points = [];

                $.each(result.routes[0].overview_path, function (i, val) {
                    line_points[line_points.length] = [val.lat(), val.lng()];
                });

                var polyline = L.polyline(line_points, {color: 'blue'}).addTo(map);

                map.fitBounds(polyline.getBounds());
            }

            this.getCourierLocation();
        }.bind(this));
    },

    componentDidMount: function () {

        if (this.props.order.status) {
            if (this.props.order.status.label === 'in transit') {
                this.initialize();
            }
        }

    },
    componentWillReceiveProps: function (props) {

        if (props.order.status) {
            if (props.order.status.label === 'in transit') {

                if (!map) {
                    this.initialize();
                } else {
                    this.getCourierLocation();
                }
            } else {
                if (map) {
                    map.remove();
                    map = null;
                    wineMarker = null;
                    $('#map').empty();
                }
            }
        }

    },
    render: function () {

        var mapStyle = {
            width: '100%',
            height: '300px'
        };

        var mainStyle = {
            display: (this.props.order.status && this.props.order.status.label === 'in transit') ? 'block' : 'none'
        };

        return (
            <div style={mainStyle}>
                <div className="row">
                    <div className="col-xs-12">
                        <h4 className="app-title order-heading">
                            Delivery in progress
                        </h4>
                    </div>
                </div>

                <div className="row">
                    <div className="col-xs-12">
                        <div id="map" style={mapStyle}></div>
                    </div>
                </div>
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
    componentWillReceiveProps: function (props) {
        if (props.clear) {
            this.clearMixinInterval();
        }
    },
    tick: function () {
        this.loadData(orderId);
    },
    loadData: function (orderId) {
        getOrderDetails(orderId, function (orderDetails) {

            if (orderDetails.order.status &&
                (orderDetails.order.status.label === 'cancelled' || orderDetails.order.status.label === 'delivered')) {
                this.clearMixinInterval();
            }

            this.setState({
                orderDetails: orderDetails
            });

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

        if (this.state.orderDetails.order.advisory_completed_at &&
            this.state.orderDetails.order.status.label !== 'cancelled' && !justCancelled
        ) {
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

                        <Done
                            order={this.state.orderDetails.order}
                        />

                        <AcceptOrder
                            order={this.state.orderDetails.order}
                            onOrderChange={this.handleOrderStatusChange}
                        />

                        <OrderTimer
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

                        <Next
                            order={this.state.orderDetails.order}
                        />

                    </div>

                    <div className="col-sm-6 col-xs-12">

                {/**
                 * right
                 */}

                        <OrderSummary
                            order={this.state.orderDetails.order}
                        />

                        <PaymentInfo
                            order={this.state.orderDetails.order}
                        />
                    </div>
                </div>
            </div>
        );

    }
});

var mainOrderComponent;

var renderOrderDetails = function () {
    if ($('body.orders').length && $('#order-details').length) {

        mainOrderComponent = React.render(
            <OrderDetails />,
            document.getElementById('order-details')
        );
    } else {
        clearMainOrderComponent();
    }
};

var clearMainOrderComponent = function () {
    if (!$('#order-details').length) {
        if (mainOrderComponent) {
            mainOrderComponent.setProps({
                clear: true
            });
            React.unmountComponentAtNode(document.getElementById('order-details'));
            mainOrderComponent = null;
        }
    }
};

var getOrderDetails = function (orderId, callback) {
    $.get('/orders/' + orderId + '/order_details',
        function (orderDetails) {
            callback(orderDetails);
        });
};

$(document).ready(renderOrderDetails);
$(document).on('page:load', renderOrderDetails);

$(document).on('page:restore', function () {
    clearMainOrderComponent();
});