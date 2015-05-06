var Router = ReactRouter;
var Link = Router.Link;


var MatchBy = React.createClass({
    getInitialState: function () {
        return {
            specificWine: ''
        };
    },
    handleSpecificWineChange: function (event) {
        this.setState({specificWine: event.target.value});
    },
    matchByFood: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-food');
    },
    matchByOccasion: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-occasion');
    },
    matchBySpecificWine: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-specific-wine');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    Match by food and what not
                    <div>
                        <div className="row">
                            <div className="col-sm-12">
                                <button
                                    className="btn btn-primary"
                                    onClick={this.matchByFood}
                                    >Food
                                </button>
                            </div>
                        </div>
                        <div className="row">
                            <div className="col-sm-12">
                                <button
                                    className="btn btn-primary"
                                    onClick={this.matchByOccasion}
                                    >Occasion
                                </button>
                            </div>
                        </div>
                        <div className="row">
                            <div className="col-sm-12">
                                <input type="text" className="form-control postcode-input"
                                       placeholder="Enter postcode (e.g. EC4Y 8AU)"
                                       onChange={this.handleSpecificWineChange}
                                       value={this.state.specificWine}
                                    />
                                <button
                                    className="btn btn-primary"
                                    onClick={this.matchBySpecificWine}
                                    >Specific Wine
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
});