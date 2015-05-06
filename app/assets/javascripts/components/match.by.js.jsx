var MatchBy = React.createClass({
    handleMatchByFood: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-food');
    },
    handleMatchByOccasion: function (e) {
        e.preventDefault();
        VyneRouter.transitionTo('match-by-occasion');
    },
    handleMatchBySpecificWine: function (e) {
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
                                    onClick={this.handleMatchByFood}
                                    >Food
                                </button>
                            </div>
                        </div>
                        <div className="row">
                            <div className="col-sm-12">
                                <button
                                    className="btn btn-primary"
                                    onClick={this.handleMatchByOccasion}
                                    >Occasion
                                </button>
                            </div>
                        </div>
                        <div className="row">
                            <div className="col-sm-12">
                                <button
                                    className="btn btn-primary"
                                    onClick={this.handleMatchBySpecificWine}
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