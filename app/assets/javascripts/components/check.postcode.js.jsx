var CheckPostcodeNew = React.createClass({
    getInitialState: function () {
        return {
            postcode: ''
        };
    },
    contextTypes: {
        router: React.PropTypes.func
    },
    componentDidMount: function () {
        if (Globals.postcode !== '') {
            this.setState({postcode: Globals.postcode});
        }
    },
    handlePostcodeChange: function (event) {
        this.setState({postcode: event.target.value});
        Globals.postcode = event.target.value;
    },
    handleCheckPostcode: function (event) {
        event.preventDefault();
        this.context.router.transitionTo('check-availability', {postcode: this.state.postcode})
    },
    render: function () {
        return (
            <div>
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