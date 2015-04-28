var CheckAvailability = React.createClass({
    getInitialState: function () {
        return {
            lat: 0,
            lng: 0
        };
    },
    contextTypes: {
        router: React.PropTypes.func
    },
    componentDidMount: function () {
        if (this.props.postcode !== '' && this.props.isValidPostcode) {
            AddressActionCreators.geocodePostcode(this.props.postcode);
        }

        //TODO: Do something else if postcode in a query was changed.
    },
    componentWillReceiveProps: function (newProps) {
        if (newProps.lat && newProps.lng) {

            if (this.state.lat !== newProps.lat || this.state.lng !== newProps.lng) {

                this.setState({
                    lat: newProps.lat,
                    lng: newProps.lng
                });

                WarehouseActionCreators.getByLocation(newProps.lat, newProps.lng);
            }
        }
    },
    render: function () {
        return (
            <div>
                <CheckAvailability.Promotion
                    promotion={this.props.promotion}
                    />
                <CheckAvailability.Results
                    postcode={this.props.postcode}
                    lat={this.props.lat}
                    lng={this.props.lng}
                    weDeliver={this.props.weDeliver}
                    />
            </div>
        );
    }
});

CheckAvailability.Results = React.createClass({
    render: function () {
        return (
            <div>
                <div className="row">
                    <div>Selected: {this.props.postcode}</div>
                    <div>lat: {this.props.lat}</div>
                    <div>lng: {this.props.lng}</div>
                    <div>we deliver!: {String(this.props.weDeliver)}</div>
                </div>
            </div>
        );
    }
});

CheckAvailability.Promotion = React.createClass({
    render: function () {

        var promotion_section = '';

        var setPromotion = function (message, shouldSignUp) {

            var signUpLink = '';

            if (shouldSignUp) {
                signUpLink = (
                    <div>
                        <div className="row">
                            <div className="col-xs-12">
                                <a href="/users/sign_up" className="btn btn-primary btn-sm">Register your promotion
                                    here</a>
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

var CheckAvailabilityContainer = Marty.createContainer(CheckAvailability, {
    listenTo: [AddressStore, WarehouseStore, PromotionStore],
    fetch: {
        postcode() {
            return AddressStore.getPostcode();
        },
        lat() {
            return AddressStore.getLat();
        },
        lng() {
            return AddressStore.getLng();
        },
        isValidPostcode() {
            return AddressStore.isValidPostcode()
        },
        weDeliver() {
            return WarehouseStore.weDeliver();
        },
        promotion(){
            return PromotionStore.promotion();
        }
    }
});