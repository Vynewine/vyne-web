var CheckPostcode = React.createClass({

    getInitialState: function () {
        return {
            showErrorLabel: false,
            filterPostcode: this.props.initialFilterPostcode,
            typingTimer: null
        };
    },
    handleChange: function (event) {

        this.setState({filterPostcode: event.target.value});

        var postcode = event.target.value.toUpperCase().trim();

        if (this.state.typingTimer) {
            clearTimeout(this.state.typingTimer);
        }

        this.setState({
            typingTimer: setTimeout(function () {

                if (postcode.length < 5) {
                    this.setState({showErrorLabel: true});
                    return;
                }

                var validated = validatePostcode(postcode);

                if (validated) {

                    this.props.onPostcodeChange(validated);

                    this.setState({showErrorLabel: false});

                } else {
                    this.setState({showErrorLabel: true});
                }
            }.bind(this), 1000)
        });

    },
    render: function () {

        var errorLabelStyle = {
            display: this.state.showErrorLabel ? 'block' : 'none'
        };

        var openedWarehouses = [];

        if (this.props.deliveryOptions.warehouses) {
            openedWarehouses = this.props.deliveryOptions.warehouses.filter(function (warehouse) {
                return warehouse.is_open
            });
        }

        //var closedWarehouses = this.props.deliveryOptions.warehouses.map(function (warehouse) {
        //    return warehouse.is_open === false;
        //});

        var deliveryLabel;

        if (openedWarehouses.length > 0) {
            deliveryLabel = (
                <p className="app-label-success">
                    Vyne delivers to your area
                </p>
            );
        } else {
            if (this.isMounted()) {
                deliveryLabel = (
                    <p className="app-label-success">
                        All closed
                    </p>
                );
            } else {
                deliveryLabel = (
                    <p className="app-label-success">
                        Checking
                    </p>
                );
            }
        }

        return (
            <div>
                <p className="animated fadeIn text-danger" style={errorLabelStyle}>Not a valid postcode</p>
                <div className="form-group">
                    <input type="text" className="form-control postcode-input"
                        placeholder="Enter postcode (e.g. EC4Y 8AU)"
                        onChange={this.handleChange}
                        value={this.state.filterPostcode}
                    />
                </div>
                {deliveryLabel}
            </div>
        );
    }
});

var ChooseDeliveryMethod = React.createClass({
    render: function () {
        return (
            <div>
                <div className="form-group form-group-submit">
                    <button type="submit" className="btn btn-primary btn-lg app-btn">Now</button>
                </div>
                <p>
                    Delivery in minutes
                </p>

                <h4 className="circled-text">or</h4>

                <p>
                    Book Daytime Slot
                    <br/>
                    To your desk in Central London
                </p>

                <div className="form-group form-group-submit">
                    <button type="submit" className="btn btn-primary btn-lg app-btn">Later</button>
                </div>
            </div>
        );
    }
});

/**
 * Top Level Controller View
 */
var Availability = React.createClass({

    getInitialState: function () {
        return {
            deliveryOptions: {}
        };
    },
    loadData: function (postcode) {
        checkWarehouseAvailability(postcode, function (deliveryOptions) {
            this.setState({deliveryOptions: deliveryOptions});
        }.bind(this));
    },
    componentDidMount: function () {
        var validated = validatePostcode(this.props.initialFilterPostcode);
        if (validated) {
            this.loadData(validated);
        }
    },
    handlePostcodeChange: function (postcode) {
        this.loadData(postcode);
    },
    render: function () {
        return (
            <div>
                <CheckPostcode
                    initialFilterPostcode={this.props.initialFilterPostcode}
                    onPostcodeChange={this.handlePostcodeChange}
                    deliveryOptions={this.state.deliveryOptions}
                />
                <ChooseDeliveryMethod
                    deliveryOptions={this.state.deliveryOptions}
                />
            </div>
        );
    }
});

var checkWarehouseAvailability = function (postcode, callback) {

    //callback(delOptions);
    //return;

    analytics.track('Postcode lookup', {
        postcode: postcode
    });

    var geocoder = new google.maps.Geocoder();

    geocoder.geocode({'address': 'London+' + postcode + '+UK'}, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {

            var warehouseResource = "/warehouses/addresses.json";

            $.get(warehouseResource,
                {
                    lat: results[0].geometry.location.lat(),
                    lng: results[0].geometry.location.lng()
                },
                function (deliveryOptions) {
                    callback(deliveryOptions);
                });
        }
    });
};
var delOptions = {
    "warehouses": [
        {
            "id": 4,
            "address": "EC4A 4AN",
            "is_open": false,
            "opening_time": "09:00",
            "closing_time": "23:00",
            "opens_today": true
        },
        {
            "id": 1,
            "address": "EC3V 1LR",
            "is_open": true,
            "opening_time": "09:00",
            "closing_time": "20:00",
            "opens_today": true
        }
    ],
    "next_opening": {
        "day": 6,
        "week_day": "Saturday",
        "opening_time": "09:00",
        "closing_time": "18:00"
    }
};


var renderAvailability = function () {

    if ($('body.availability').length) {

        var postCode = '';
        var queryHash = getUrlVars();

        if (queryHash["postcode"]) {
            postCode = getUrlVars()["postcode"].replace('+', ' ').toUpperCase().trim();
        }

        React.render(<Availability initialFilterPostcode={postCode} />,
            document.getElementById('availability-component'));
    }
};

$(document).on('page:load', renderAvailability);
$(document).ready(renderAvailability);
