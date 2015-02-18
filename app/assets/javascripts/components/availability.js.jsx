var token = $('meta[name="csrf-token"]').last().attr('content');

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

        /**
         * Check validity of postcode only when user stops typing
         */
        this.setState({
            typingTimer: setTimeout(function () {

                if (postcode.length < 5) {
                    this.setState({showErrorLabel: true});
                    return;
                }

                var validated = validatePostcode(postcode);

                if (validated) {

                    /**
                     * Handled in Availability component. Comes back via props deliveryOptions
                     */
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
        var closedWarehouses = [];

        if (this.props.deliveryOptions.warehouses) {
            openedWarehouses = this.props.deliveryOptions.warehouses.filter(function (warehouse) {
                return warehouse.is_open
            });

            closedWarehouses = this.props.deliveryOptions.warehouses.map(function (warehouse) {
                return warehouse.is_open === false;
            });
        }

        var labelClass = 'app-label loading';
        var labelText = 'Checking';

        if (this.isMounted()) {
            if (openedWarehouses.length > 0) {
                labelClass = 'app-label success fadeIn';
                labelText = 'Vyne delivers to your area';
            } else if (closedWarehouses.length > 0) {
                labelClass = 'app-label danger';
                labelText = 'All closed';
            }
            else {
                labelClass = 'app-label danger';
                labelText = 'We don\'t deliver';
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

                <p className={labelClass}>
                    {labelText}
                </p>
            </div>
        );
    }
});

var ChooseDeliveryMethod = React.createClass({
    getInitialState: function () {
        return {
            openedWarehouses: [],
            warehousesWithBookableSlots: [],
            filterPostcode: this.props.initialFilterPostcode
        };
    },
    componentWillReceiveProps: function (nextProps) {
        if (nextProps.deliveryOptions.warehouses) {

            this.setState({
                openedWarehouses: nextProps.deliveryOptions.warehouses.filter(function (warehouse) {
                    return warehouse.is_open
                })
            });

            this.setState({
                warehousesWithBookableSlots: nextProps.deliveryOptions.warehouses.filter(function (warehouse) {
                    return warehouse.delivery_slots && warehouse.delivery_slots.length > 0
                })
            });
        }
    },
    deliverLater: function () {
        this.props.onPageChange('choseSlot', this.state.warehousesWithBookableSlots)
    },
    render: function () {

        var deliverNow = '';
        var deliverLater = '';
        var or = '';

        if (this.state.openedWarehouses.length) {
            deliverNow = (
                <div>
                    <div className="form-group form-group-submit">
                        <form method="post" action={"shop/neworder?postcode=" + (this.state.filterPostcode).replace(' ', '+')}>
                            <button type="submit" className="btn btn-primary btn-lg app-btn">Now</button>
                            <input name="warehouses" type="hidden" value={JSON.stringify({warehouses: this.state.openedWarehouses})} />
                            <input name="authenticity_token" type="hidden" value={token} />
                        </form>
                    </div>
                    <p>
                        Delivery in minutes
                    </p>
                </div>
            );
        }

        if (this.state.warehousesWithBookableSlots.length) {
            deliverLater = (
                <div>
                    <p>
                        Book Daytime Slot
                        <br/>
                        To your desk in Central London
                    </p>

                    <div className="form-group form-group-submit">
                        <button type="submit" onClick={this.deliverLater} className="btn btn-primary btn-lg app-btn">Later</button>
                    </div>
                </div>
            );
        }

        if (this.state.openedWarehouses.length && this.state.warehousesWithBookableSlots.length) {
            or = (
                <div>
                    <h4 className="circled-text">or</h4>
                </div>
            );
        }

        return (
            <div>
            {deliverNow}
            {or}
            {deliverLater}
            </div>
        );
    }
});

var ChooseBookingSlot = React.createClass({

    getInitialState: function () {
        return {
            fromSlot: '',
            filterPostcode: this.props.initialFilterPostcode,
            selectedSlot: '(Please select one of the available slots above)',
            warehousesWithBookableSlots: []
        };
    },
    selectSlot: function (fromSlot, slot) {
        this.setState({
            fromSlot: fromSlot,
            selectedSlot: slot.day + ' ' + slot.from + ' ' + slot.to
        });
    },
    render: function () {

        //TODO: There can be more than one warehouse with slots available
        var deliverySlots = this.props.deliveryOptions.warehouses[0].delivery_slots.map(function (slot) {

            return (
                <button key={slot.from}
                    className={'btn btn-lg' + (slot.from === this.state.fromSlot ? ' btn-success' : ' btn-default')}
                    disabled={!slot.available}
                    onClick={this.selectSlot.bind(this, slot.from, slot)}
                >
                        {slot.day} {slot.from} - {slot.to}
                    {slot.available ? '' : <br>(Full)</br> }
                </button>
            )
        }.bind(this));

        return (
            <div>
                <h4>
                    Next available booking slots for  {this.state.filterPostcode}
                </h4>

                <div className="form-group small">
                    Choose your delivery slot
                </div>

                <div className="btn-group-vertical">

                {deliverySlots}

                </div>

                <h4>
                    You selected: {this.state.selectedSlot}
                </h4>

                <div className="form-group form-group-submit">
                    <form method="post" action={"shop/neworder?postcode=" + (this.state.filterPostcode).replace(' ', '+')}>
                        <button type="submit" className="btn btn-primary btn-lg app-btn" disabled={!this.state.fromSlot}>Book Slot</button>
                        <input name="warehouses" type="hidden" value={JSON.stringify({warehouses: this.props.warehousesWithBookableSlots})} />
                        <input name="selected_slot" type="hidden" value={this.state.fromSlot} />
                        <input name="authenticity_token" type="hidden" value={token} />
                    </form>
                </div>
            </div>
        )
    }
});

/**
 * Top Level Controller View
 */
var Availability = React.createClass({

    getInitialState: function () {
        return {
            deliveryOptions: {},
            currentPage: 'check'
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
    handlePageChange: function (page, data) {
        this.setState({
            currentPage: page,
            data: data
        });
    },
    render: function () {
        var partial;

        switch (this.state.currentPage) {
            case 'check':
                partial = (
                    <div>
                        <CheckPostcode
                            initialFilterPostcode={this.props.initialFilterPostcode}
                            onPostcodeChange={this.handlePostcodeChange}
                            deliveryOptions={this.state.deliveryOptions}
                        />
                        <ChooseDeliveryMethod
                            deliveryOptions={this.state.deliveryOptions}
                            initialFilterPostcode={this.props.initialFilterPostcode}
                            onPageChange={this.handlePageChange}
                        />
                    </div>);
                break;
            case 'choseSlot':
                partial = <ChooseBookingSlot
                    deliveryOptions={this.state.deliveryOptions}
                    initialFilterPostcode={this.props.initialFilterPostcode}
                    warehousesWithBookableSlots={this.state.data}
                />;
        }

        return partial;
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
            "is_open": true,
            "opening_time": "09:00",
            "closing_time": "23:00",
            "opens_today": true,
            "delivery_slots": [
                {"day": "Monday", "from": "13:00", "to": "14:00", "available": true},
                {"day": "Monday", "from": "14:00", "to": "15:00", "available": true},
                {"day": "Monday", "from": "15:00", "to": "16:00", "available": false},
                {"day": "Monday", "from": "16:00", "to": "17:00", "available": true}
            ]
        },
        {
            "id": 1,
            "address": "EC3V 1LR",
            "is_open": false,
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
    },
    "delivery_slots": [
        {"day": "Monday", "date": "2015/02/15", "from": "13:00", "to": "14:00", "full": true, "warehouse_id": 1},
        {"day": "Monday", "date": "2015/02/15", "from": "14:00", "to": "15:00", "full": true, "warehouse_id": 1},
        {"day": "Monday", "date": "2015/02/15", "from": "15:00", "to": "16:00", "full": false, "warehouse_id": 2},
        {"day": "Monday", "date": "2015/02/15", "from": "16:00", "to": "17:00", "full": true, "warehouse_id": 1}
    ]
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
