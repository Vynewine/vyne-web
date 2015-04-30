var CheckPostcodeNew = React.createClass({
    getInitialState: function () {
        return {
            postcode: '',
            showInvalidPostcodeError: false
        };
    },
    contextTypes: {
        router: React.PropTypes.func
    },
    componentDidMount: function () {
        if (this.props.postcode !== '') {
            this.setState({postcode: this.props.postcode});
        }
    },
    componentWillReceiveProps: function (newProps) {
        this.setState({
            showInvalidPostcodeError: !newProps.isValidPostcode
        });
    },
    handlePostcodeChange: function (event) {
        this.setState({postcode: event.target.value});
    },
    handleCheckPostcode: function (event) {
        event.preventDefault();
        AddressActionCreators.validatePostcode(this.state.postcode);
    },
    render: function () {

        var invalidPostcodeError = '';

        if(this.state.showInvalidPostcodeError) {
            invalidPostcodeError = (<p className="animated fadeIn text-danger">Not a valid postcode</p>);
        } else {
            invalidPostcodeError = '';
        }

        return (
            <div>
                {invalidPostcodeError}
                <form className="form home-form">
                    <div className="form-group">
                        <input type="text" className="form-control postcode-input"
                               placeholder="Enter postcode (e.g. EC4Y 8AU)"
                               onChange={this.handlePostcodeChange}
                               value={this.state.postcode}

                            />
                    </div>
                    <div className="form-group form-group-submit">
                        <input type="submit" onClick={this.handleCheckPostcode}
                               className="btn btn-primary btn-lg btn-block"
                               value="Check Availability"/>
                    </div>
                </form>
            </div>
        );
    }
});

var CheckPostcodeNewContainer = Marty.createContainer(CheckPostcodeNew, {
    listenTo: AddressStore,
    fetch: {
        postcode() {
            return AddressStore.getPostcode()
        },
        isValidPostcode(){
            return AddressStore.isValidPostcode()
        }
    }
});