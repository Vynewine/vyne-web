Payment = React.createClass({
    handlePayment: function(e){
        e.preventDefault();
        console.log('nice');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">
                        Payment
                        <button
                            className="btn btn-primary"
                            onClick={this.handlePayment}
                            >Pay
                        </button>
                    </div>
                </div>
            </div>
        );
    }
});