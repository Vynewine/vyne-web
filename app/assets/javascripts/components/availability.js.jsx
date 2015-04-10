var token = $('meta[name="csrf-token"]').last().attr('content');

var Promotion = React.createClass({
    render: function () {

        var promotion_section = '';

        var setPromotion = function (message, shouldSignUp) {

            var signUpLink = '';

            if (shouldSignUp) {
                signUpLink = (
                    <div>
                        <div className="row">
                            <div className="col-xs-12">
                                <a href="/users/sign_up" className="btn btn-primary btn-sm" >Register your promotion here</a>
                            </div>
                        </div>
                    </div>
                )
            }

            promotion_section = (
                <div>
                    <div className="row">
                        <div className="col-xs-12 promotion-message">
                            <i className="fa fa-gift"></i> {message}
                        {signUpLink}
                        </div>
                    </div>
                </div>
            )
        };


        if (this.props.deliveryOptions.today_warehouse) {

            if (this.props.deliveryOptions.promotion) {

                var promotion = this.props.deliveryOptions.promotion;

                if (!this.props.deliveryOptions.today_warehouse.id) {
                    setPromotion('We currently don\'t deliver to your area. Register now and we\'ll save' +
                    ' your promotion in your account.', true);

                } else {
                    setPromotion('Your promotion (code ' + promotion.code +
                    ' - "' + promotion.title + '") will be applied to your order automatically upon checkout.', false);
                }
            } else {
                return false;
            }
        }


        return (
            <div>
            {promotion_section}
            </div>
        )
    }
});

var CheckPostcode = React.createClass({

    getInitialState: function () {
        return {
            showErrorLabel: false,
            filterPostcode: this.props.initialFilterPostcode,
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
        var labelText = 'Checking your postcode';

        if (this.props.deliveryOptions.today_warehouse) {
            if (!this.props.deliveryOptions.today_warehouse.id) {
                labelClass = 'app-label danger';
                labelText = 'Not available in your area yet';
            } else {
                labelClass = 'app-label success fadeIn';

                if (this.props.deliveryOptions.today_warehouse.coming_soon) {
                    labelText = 'On demand delivery available in West London ' +
                    moment(this.props.deliveryOptions.today_warehouse.active_from).format('dddd MMMM Do');
                } else {

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
            filterPostcode: this.props.initialFilterPostcode,
            nextOpenWarehouse: {}
        };
    },
    componentWillReceiveProps: function (nextProps) {

        this.setState({
            warehouse: nextProps.deliveryOptions.today_warehouse,
            liveDeliveryEnabled: nextProps.deliveryOptions.today_warehouse.is_open,
            nextOpenWarehouse: nextProps.deliveryOptions.next_open_warehouse,
            filterPostcode: nextProps.initialFilterPostcode
        });
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

                    <h4>Delivery in minutes</h4>

                    <p>
                    </p>
                </div>
            );
        } else if (this.state.warehouse.opens_today && this.state.warehouse.opening_time) {
            deliverNow = (
                <h4>
                    Instant delivery is only available in your area
                    <br/>
                    between {this.state.warehouse.opening_time}-{this.state.warehouse.closing_time}
                </h4>
            );
        } else if (this.state.warehouse.coming_soon) {
            deliverNow = '';

        } else if (this.state.nextOpenWarehouse && this.state.nextOpenWarehouse.opening_time) {
            deliverNow = (
                <h4>
                    Next instant delivery to your area will be on {this.state.nextOpenWarehouse.week_day}
                    <br/>
                    between {this.state.nextOpenWarehouse.opening_time}-{this.state.nextOpenWarehouse.closing_time}
                </h4>
            );
        } else {
            deliverNow = '';
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
        var slots = nextProps.deliveryOptions.delivery_slots;
        var slotDate = '';
        var slotFrom = '';
        var slotTo = '';
        var slotWarehouse = '';

        if (slots && slots.length) {
            slotDate = slots[0].date;
            slotFrom = slots[0].from;
            slotTo = slots[0].to;
            slotWarehouse = slots[0].warehouse_id;
        }

        this.setState({
            warehouse: nextProps.deliveryOptions.today_warehouse,
            deliverySlots: slots,
            daytimeSlotsAvailable: nextProps.deliveryOptions.daytime_slots_available,
            liveDeliveryEnabled: nextProps.deliveryOptions.today_warehouse.is_open,
            slotDate: slotDate,
            slotFrom: slotFrom,
            slotTo: slotTo,
            slotWarehouse: slotWarehouse,
            filterPostcode: nextProps.initialFilterPostcode
        });
    },
    selectSlot: function (event) {
        var slot = $(event.target).find("option:selected").data('value');
        this.setState({
            selectedSlot: slot,
            selectedSlotText: moment(slot.date).format('dddd MMMM Do') + ' between ' + slot.from + ' and ' + slot.to,
            slotDate: slot.date,
            slotFrom: slot.from,
            slotTo: slot.to,
            slotWarehouse: slot.warehouse_id
        });
    },
    render: function () {
        var options = [];
        var deliverLater = '';
        var or = '';
        var slotsMessage = '';

        if (this.state.deliverySlots.length) {

            this.state.deliverySlots.map(function (slot) {
                var key = slot.date + ',' + slot.from + ',' + slot.to;
                var text = slot.day + ' ' + slot.from + ' - ' + slot.to;

                if (this.state.warehouse.coming_soon) {
                    text = slot.day + ' (' + moment(slot.date).format('MMM Do') + ') ' + slot.from + ' - ' + slot.to;
                }

                options.push(<option key={key} data-value={JSON.stringify(slot)} value={key} >{text}</option>)
            }.bind(this));


            if (this.state.daytimeSlotsAvailable && this.state.warehouse.opens_today || this.state.liveDeliveryEnabled) {
                slotsMessage = (
                    <div>
                        <p>
                        </p>

                        <h4> Book in advance for later delivery </h4>

                    </div>
                );
            }
            else if (!this.state.daytimeSlotsAvailable && !this.state.liveDeliveryEnabled) {
                slotsMessage = (
                    <div>
                        <p>
                        </p>
                        <h4>
                            Work in Central London&#63;
                            <br/>
                            Enter your work postcode for&nbsp;
                            <strong>bookable daytime slots today</strong>
                        </h4>
                        <p>
                            <h4 className="circled-text">or</h4>
                        </p>
                        <h4>Book one of the evening slots below</h4>
                    </div>
                );
            }
            else if (!this.state.warehouse.opens_today) {
                slotsMessage = (
                    <div>
                        <p>
                        </p>
                        <h4> Book in advance for later delivery</h4>
                    </div>
                );
            }


            deliverLater = (
                <div>

                {slotsMessage}

                    <form method="get" action="shop/neworder">
                        <div className="form-group">
                            <select className="form-control app-btn" onChange={this.selectSlot}>
                            {options}
                            </select>
                        </div>

                        <input name="postcode" type="hidden" value={(this.state.filterPostcode)} />
                        <input name="warehouse_id" type="hidden" value={this.state.slotWarehouse} />
                        <input name="slot_date" type="hidden" value={this.state.slotDate} />
                        <input name="slot_from" type="hidden" value={this.state.slotFrom} />
                        <input name="slot_to" type="hidden" value={this.state.slotTo} />
                        <div className="form-group">
                            <button type="submit" className="btn btn-primary btn-lg app-btn">Book Now</button>
                        </div>
                    </form>
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

var MailingList = React.createClass({
    getInitialState: function () {
        return {
            shouldSignUpForList: false,
            email: '',
            showThankYou: false
        };
    },
    handleChange: function (event) {
        this.setState({email: event.target.value});
    },
    componentWillReceiveProps: function (nextProps) {
        if (!nextProps.deliveryOptions.today_warehouse.id) {

            this.setState({
                shouldSignUpForList: true
            });
        } else {
            this.setState({
                shouldSignUpForList: false
            });
        }
    },
    signUp: function (email) {
        mailingListSignUp(email, function (error) {

            if (error) {
                this.setState({
                    error: error
                });
            } else {
                this.setState({
                    shouldSignUpForList: false,
                    showThankYou: true
                });
            }

        }.bind(this));
    },
    render: function () {

        var signupForm = '';
        var error = '';

        var errorLabelStyle = {
            display: this.state.error ? 'block' : 'none'
        };

        if (this.state.error) {
            error = (
                <div>
                    <p className="animated fadeIn text-danger" style={errorLabelStyle}>{this.state.error}</p>
                    <p></p>
                </div>
            );
        }

        if (this.state.shouldSignUpForList && !this.state.showThankYou) {
            signupForm = (
                <div>
                    <h4>
                        Work in Central London&#63;
                        <br/>
                        Enter your work postcode for&nbsp;
                        <strong>bookable daytime slots</strong>
                    </h4>

                    <div className="form-group form-group-submit">
                        <h4>Or we can let you know when we’re coming your way</h4>
                        <div className="form-group">
                            <input
                                className="form-control app-btn postcode-input"
                                type="text"
                                placeholder="Email"
                                onChange={this.handleChange}
                            />
                        </div>
                        <button
                            type="submit"
                            className="btn btn-primary btn-lg app-btn"
                            onClick={this.signUp.bind(this, this.state.email)}>Sign Up</button>

                    </div>
                {error}
                </div>
            );
        } else if (this.state.showThankYou) {
            signupForm = (
                <h4>
                    Thank you
                </h4>
            );
        } else {
            signupForm = '';
        }

        return (
            <div>
            {signupForm}
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
            deliveryOptions: {},
            postcode: this.props.initialFilterPostcode
        };
    },
    loadData: function (postcode) {
        checkWarehouseAvailability(postcode, function (deliveryOptions) {
            this.setState({
                deliveryOptions: deliveryOptions,
                postcode: postcode
            });
        }.bind(this));
    },
    handlePostcodeChange: function (postcode) {
        this.loadData(postcode);
    },
    render: function () {

        return (
            <div>
                <Promotion
                    deliveryOptions={this.state.deliveryOptions}
                />
                <CheckPostcode
                    initialFilterPostcode={this.state.postcode}
                    onPostcodeChange={this.handlePostcodeChange}
                    deliveryOptions={this.state.deliveryOptions}
                />
                <LiveDelivery
                    deliveryOptions={this.state.deliveryOptions}
                    initialFilterPostcode={this.state.postcode}
                />
                <BlockDelivery
                    deliveryOptions={this.state.deliveryOptions}
                    initialFilterPostcode={this.state.postcode}
                />
                <MailingList
                    deliveryOptions={this.state.deliveryOptions}
                    initialFilterPostcode={this.state.postcode}
                />
            </div>
        );
    }
});

var checkWarehouseAvailability = function (postcode, callback) {

    //We deliver to your area Now
    //Have daytime and evening bookable slots
    //callback(scenario_01);

    //We don't deliver to your area Now
    //We will deliver later today
    //Have daytime and evening bookable slots
    //callback(scenario_02);

    //We don't deliver to your area Now
    //We will deliver later today
    //Have only evening bookable slots
    //callback(scenario_03);

    //We don't deliver to your area Now
    //We are closed in your area today
    //Have daytime and evening bookable slots for other days
    //callback(scenario_04);

    //We don't deliver to your area Now
    //We are closed in your area today
    //Have only evening bookable slots for other days
    //callback(scenario_05);

    //We don't deliver to your area yet at all
    //callback(scenario_06);
    //return;

    //We are open now
    //No daytime delivery options
    //callback(scenario_07);
    //return;


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

var delOptions = {
    "today_warehouse": {
        "id": 1,
        "address": "W1F 8BH",
        "is_open": true,
        "opening_time": "17:00",
        "closing_time": "20:30",
        "opens_today": true,
        "title": "Vyne QH Soho"
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
            "from": "14:00",
            "to": "15:00",
            "date": "2015-02-22",
            "day": "Wednesday",
            "warehouse_id": 1,
            "title": "Vyne QH Soho"
        },
        {
            "from": "15:00",
            "to": "16:00",
            "date": "2015-12-22",
            "day": "Wednesday",
            "warehouse_id": 4,
            "title": "Vyne QH Soho"
        },
        {
            "from": "14:00",
            "to": "15:00",
            "date": "2015-12-23",
            "day": "Thursday",
            "warehouse_id": 1,
            "title": "Vyne QH Soho"
        },
        {
            "from": "15:00",
            "to": "16:00",
            "date": "2015-12-23",
            "day": "Thursday",
            "warehouse_id": 4,
            "title": "Vyne QH Soho"
        }

    ]
};


var scenario_01 = delOptions;

var scenario_02 = $.extend(true, {}, delOptions);
scenario_02.today_warehouse.is_open = false;


var scenario_03 = $.extend(true, {}, delOptions);
scenario_03.today_warehouse.is_open = false;
scenario_03.daytime_slots_available = false;

var scenario_04 = $.extend(true, {}, delOptions);
scenario_04.today_warehouse.is_open = false;
scenario_04.today_warehouse.opens_today = false;

var scenario_05 = $.extend(true, {}, delOptions);
scenario_05.today_warehouse.is_open = false;
scenario_05.today_warehouse.opens_today = false;
scenario_05.daytime_slots_available = false;


var scenario_06 = $.extend(true, {}, delOptions);
scenario_06.today_warehouse = {};
scenario_06.next_open_warehouse = {};

var scenario_07 = {
    "today_warehouse": {
        "id": 4,
        "address": "W1F 8BH",
        "is_open": true,
        "opening_time": "11:00",
        "closing_time": "13:30",
        "opens_today": true,
        "title": "Vyne HQ"
    },
    "next_open_warehouse": {
        "day": 7,
        "week_day": null,
        "opening_time": null,
        "closing_time": null
    },
    "delivery_slots": [
        {
            "from": "12:00",
            "to": "13:00",
            "date": "2015-02-20",
            "day": "Today",
            "warehouse_id": 4,
            "title": "Vyne HQ",
            "type": "live"
        },
        {
            "from": "17:00",
            "to": "18:00",
            "date": "2015-02-25",
            "day": "Wednesday",
            "warehouse_id": 6,
            "title": "The Winemakers Club",
            "type": "live"
        },
        {
            "from": "18:00",
            "to": "19:00",
            "date": "2015-02-25",
            "day": "Wednesday",
            "warehouse_id": 6,
            "title": "The Winemakers Club",
            "type": "live"
        },
        {
            "from": "19:00",
            "to": "20:00",
            "date": "2015-02-25",
            "day": "Wednesday",
            "warehouse_id": 6,
            "title": "The Winemakers Club",
            "type": "live"
        },
        {
            "from": "20:00",
            "to": "21:00",
            "date": "2015-02-25",
            "day": "Wednesday",
            "warehouse_id": 6,
            "title": "The Winemakers Club",
            "type": "live"
        }
    ],
    "daytime_slots_available": false
};
