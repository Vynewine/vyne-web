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
                <div className="row">
                    <div>We Deliver to: {this.context.router.getCurrentParams().postcode}</div>
                    <div>Selected: {this.props.postcode}</div>
                    <div>lat: {this.props.lat}</div>
                    <div>lng: {this.props.lng}</div>
                    <div>we deliver!: {String(this.props.weDeliver)}</div>
                </div>
            </div>
        );
    }
});

var CheckAvailabilityContainer = Marty.createContainer(CheckAvailability, {
    listenTo: [AddressStore, WarehouseStore],
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
        }
    }
});