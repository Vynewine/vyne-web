Address = React.createClass({
    handleAddressSelection: function(e){
        e.preventDefault();
        VyneRouter.transitionTo('payment');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">
                        Address
                        <button
                            className="btn btn-primary"
                            onClick={this.handleAddressSelection}
                            >Confirm Address
                        </button>
                    </div>
                </div>
            </div>
        );
    }
});