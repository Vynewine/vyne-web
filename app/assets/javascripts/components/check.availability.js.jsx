var CheckAvailability = React.createClass({
    getInitialState: function () {
        return {
            latLng: {lat: 0, lng: 0}
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
        if (newProps.latLng && newProps.latLng.lat && newProps.latLng.lng) {

            if (this.state.latLng.lat !== newProps.latLng.lat || this.state.latLng.lng !== newProps.latLng.lng) {

                this.setState({
                    latLng: newProps.latLng
                });

                WarehouseActionCreators.getByLocation(newProps.latLng);
            }
        }
    },
    render: function () {
        return (
            <div>
                <CheckAvailability.Promotion
                    promotion={this.props.promotion}
                    weDeliver={this.props.weDeliver}
                    />
                <CheckAvailability.Results
                    postcode={this.props.postcode}
                    latLng={this.props.latLng}
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
                    <div>lat: {this.props.latLng.lat}</div>
                    <div>lng: {this.props.latLng.lng}</div>
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


        if (this.props.promotion.code && typeof(this.props.weDeliver) !== 'undefined') {

            var promotion = this.props.promotion;

            if (!this.props.weDeliver) {
                setPromotion('We currently don\'t deliver to your area. Register now and we\'ll save' +
                ' your promotion in your account.', true);

            } else {
                setPromotion('Your promotion (code ' + promotion.code +
                ' - "' + promotion.title + '") will be applied to your order automatically upon checkout.', false);
            }
        } else {
            return false;
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
        latLng() {
            return AddressStore.getLatLng();
        },
        isValidPostcode() {
            return AddressStore.isValidPostcode()
        },
        weDeliver() {
            return WarehouseStore.weDeliver();
        },
        promotion(){
            return PromotionStore.getPromotion();
        }
    },
    pending() {
        return <div className='loading'>Loading...</div>;
    },
    failed(errors) {
        console.log(errors)
        return <div className='error'>Failed to load room. {errors}</div>;
    }
});