var token = $('meta[name="csrf-token"]').last().attr('content');

var CheckPostcode = React.createClass({

    getInitialState: function () {
        return {
            showErrorLabel: false,
            filterPostcode: $.cookie('postcode'),
            typingTimer: null
        };
    },
    componentDidMount: function () {
        if (this.state.filterPostcode) {
            this.props.onPostcodeChange(this.state.filterPostcode);
        }
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

        var labelClass = 'app-label loading';
        var labelText = 'Please enter your postcode';

        if (this.isMounted()) {

            if (this.props.deliveryOptions.today_warehouse) {
                if (!this.props.deliveryOptions.today_warehouse.id) {
                    labelClass = 'app-label danger';
                    labelText = 'We don\'t deliver';
                } else {
                    labelClass = 'app-label success fadeIn';
                    labelText = 'Vyne delivers to your area';
                }
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

var LiveDelivery = React.createClass({
    getInitialState: function () {
        return {
            warehouse: {},
            liveDeliveryEnabled: false,
            filterPostcode: this.props.initialFilterPostcode
        };
    },
    componentWillReceiveProps: function (nextProps) {
        if (nextProps.deliveryOptions.today_warehouse.id) {

            this.setState({
                warehouse: nextProps.deliveryOptions.today_warehouse,
                liveDeliveryEnabled: nextProps.deliveryOptions.today_warehouse.is_open
            });
        }
    },
    render: function () {

        var deliverNow = '';

        if (this.state.liveDeliveryEnabled) {
            deliverNow = (
                <div>
                    <div className="form-group form-group-submit">
                        <form method="get" action="shop/neworder">
                            <button type="submit" className="btn btn-primary btn-lg app-btn">Now</button>
                            <input name="warehouse_id" type="hidden" value={this.state.warehouse.id} />
                            <input name="postcode" type="hidden" value={(this.state.filterPostcode)} />
                        </form>
                    </div>
                    <p>
                        Delivery in minutes
                    </p>
                </div>
            );
        }

        return (
            <div>
            {deliverNow}
            </div>
        );
    }
});

var BlockDelivery = React.createClass({
    getInitialState: function () {
        return {
            warehouse: {},
            filterPostcode: this.props.initialFilterPostcode,
            deliverySlots: [],
            liveDeliveryEnabled: false
        };
    },
    componentWillReceiveProps: function (nextProps) {
        if (nextProps.deliveryOptions.today_warehouse.id) {

            var slots = nextProps.deliveryOptions.delivery_slots;
            var slotDate = '';
            var slotFrom = '';
            var slotTo = '';

            if(slots) {
                slotDate = slots[0].date;
                slotFrom = slots[0].from;
                slotTo = slots[0].to;
            }

            this.setState({
                warehouse: nextProps.deliveryOptions.today_warehouse,
                deliverySlots: slots,
                daytimeSlotsAvailable: nextProps.deliveryOptions.daytime_slots_available,
                liveDeliveryEnabled: nextProps.deliveryOptions.today_warehouse.is_open,
                slotDate: slotDate,
                slotFrom: slotFrom,
                slotTo: slotTo
            });
        }
    },
    selectSlot: function (event) {
        var slot = $(event.target).find("option:selected").data('value');
        this.setState({
            selectedSlot: slot,
            selectedSlotText: moment(slot.date).format('dddd MMMM Do') + ' between ' + slot.from + ' and ' + slot.to,
            slotDate: slot.date,
            slotFrom: slot.from,
            slotTo: slot.to
        });
    },
    render: function () {
        var options = [];
        var deliverLater = '';
        var or = '';

        if (this.state.deliverySlots.length) {

            this.state.deliverySlots.map(function (slot) {
                var key = slot.date + ',' + slot.from + ',' + slot.to;
                options.push(<option key={key} data-value={JSON.stringify(slot)} value={key} >{slot.day} {slot.from} - {slot.to}</option>)
            }.bind(this));

            deliverLater = (
                <div>
                    <p>
                        Book Daytime Slot
                        <br/>
                        To your desk in Central London
                    </p>


                    <div className="form-group form-group-submit">
                        <form method="get" action="shop/neworder">
                            <select className="form-control" onChange={this.selectSlot}>
                            {options}
                            </select>
                            <input name="postcode" type="hidden" value={(this.state.filterPostcode)} />
                            <input name="warehouse_id" type="hidden" value={this.state.warehouse.id} />
                            <input name="slot_date" type="hidden" value={this.state.slotDate} />
                            <input name="slot_from" type="hidden" value={this.state.slotFrom} />
                            <input name="slot_to" type="hidden" value={this.state.slotTo} />
                            <button type="submit" className="btn btn-primary btn-lg app-btn">Book a slot</button>
                        </form>
                    </div>
                </div>
            );
        }

        if (this.state.liveDeliveryEnabled && this.state.deliverySlots.length) {
            or = (
                <div>
                    <h4 className="circled-text">or</h4>
                </div>
            );
        }

        return (
            <div>
            {or}
            {deliverLater}
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
                <LiveDelivery
                    deliveryOptions={this.state.deliveryOptions}
                    initialFilterPostcode={this.props.initialFilterPostcode}
                />
                <BlockDelivery
                    deliveryOptions={this.state.deliveryOptions}
                    initialFilterPostcode={this.props.initialFilterPostcode}
                />
            </div>
        );
    }
});

var checkWarehouseAvailability = function (postcode, callback) {

    callback(delOptions);
    return;

    analytics.track('Postcode lookup', {
        postcode: postcode
    });

    var geocoder = new google.maps.Geocoder();

    geocoder.geocode({'address': 'London+' + postcode + '+UK'}, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {

            var warehouseResource = "/merchants/";

            $.get(warehouseResource,
                {
                    lat: results[0].geometry.location.lat(),
                    lng: results[0].geometry.location.lng(),
                    postcode: postcode
                },
                function (deliveryOptions) {
                    callback(deliveryOptions);
                });
        }
    });
};
var delOptions = {
    "today_warehouse": {
        "id": 1,
        "address": "W1F 8BH",
        "is_open": true,
        "opening_time": "17:00",
        "closing_time": "20:30",
        "opens_today": true,
        "title": "Vynz QH Soho"
    },
    "next_open_warehouse": {
        "day": 1,
        "week_day": "Monday",
        "opening_time": "17:00",
        "closing_time": "20:30"
    },
    "daytime_slots_available": true,
    "delivery_slots": [
        {
            "from": "14:50",
            "to": "15:00",
            "date": "2015-02-19",
            "day": "Wednesday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "15:00",
            "to": "16:00",
            "date": "1996-01-08",
            "day": "Monday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "16:00",
            "to": "17:00",
            "date": "1996-01-08",
            "day": "Monday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "17:00",
            "to": "18:00",
            "date": "1996-01-08",
            "day": "Monday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "18:00",
            "to": "19:00",
            "date": "1996-01-08",
            "day": "Monday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "19:00",
            "to": "20:00",
            "date": "1996-01-08",
            "day": "Monday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "14:00",
            "to": "15:00",
            "date": "1996-01-09",
            "day": "Tuesday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "15:00",
            "to": "16:00",
            "date": "1996-01-09",
            "day": "Tuesday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "16:00",
            "to": "17:00",
            "date": "1996-01-09",
            "day": "Tuesday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "17:00",
            "to": "18:00",
            "date": "1996-01-09",
            "day": "Tuesday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        },
        {
            "from": "18:00",
            "to": "19:00",
            "date": "1996-01-09",
            "day": "Tuesday",
            "warehouse_id": 298486374,
            "title": "Vynz QH Soho"
        }
    ]
};


var renderAvailability = function () {

    if ($('body.availability').length) {

        var postCode = '';
        var queryHash = getUrlVars();

        if (queryHash["postcode"]) {
            postCode = getUrlVars()["postcode"].replace('+', ' ').toUpperCase().trim();
        }

        if (!postCode && $.cookie('postcode')) {
            postCode = $.cookie('postcode')
        }

        React.render(<Availability initialFilterPostcode={postCode} />,
            document.getElementById('availability-component'));
    }
};

$(document).on('page:load', renderAvailability);
$(document).ready(renderAvailability);
