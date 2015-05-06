var MatchByOccasion = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    render: function () {
        var name = this.context.router.getCurrentPath();
        return (
            <div>
                Great occasion
                <Router.RouteHandler key={name}/>
            </div>
        );
    }
});

MatchByOccasion.Occasions = React.createClass({
    handleOccasionChoice: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-occasion-select-type');
    },
    render: function () {
        return (
            <div>

                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.handleOccasionChoice}
                            >Solo
                        </button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.handleOccasionChoice}
                            >Date
                        </button>
                    </div>
                </div>
            </div>
        );
    }
});

MatchByOccasion.WineTypes = React.createClass({
    handleTypeSelection: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('cart-review');
    },
    render: function () {
        return (
            <div>

                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.handleTypeSelection}
                            >Red
                        </button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.handleTypeSelection}
                            >White
                        </button>
                    </div>
                </div>
            </div>
        );
    }
});