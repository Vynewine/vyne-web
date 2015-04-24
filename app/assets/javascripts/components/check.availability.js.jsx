var CheckAvailability = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    render: function() {
        return (
            <div>

                <div className="row">
                    We Deliver to: {this.context.router.getCurrentParams().postcode}
                </div>
            </div>
        );
    }
});