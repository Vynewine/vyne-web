var CheckAvailability = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    componentDidMount: function () {
        if (this.props.postcode !== '' && this.props.isValidPostcode) {
            AddressActionCreators.geocodePostcode(this.props.postcode);
        }
    },
    componentWillReceiveProps: function (newProps) {
        if(newProps.lat && newProps.lng) {
            //Check availability
        }
    },
    render: function() {
        return (
            <div>
                <div className="row">
                    <div>We Deliver to: {this.context.router.getCurrentParams().postcode}</div>
                    <div>Selected: {this.props.postcode}</div>
                    <div>lat: {this.props.lat}</div>
                    <div>lng: {this.props.lng}</div>
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
        lat(){
            return AddressStore.getLat();
        },
        lng(){
            return AddressStore.getLng();
        },
        isValidPostcode(){
            return AddressStore.isValidPostcode()
        }
    }
});