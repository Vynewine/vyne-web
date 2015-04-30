var Router = ReactRouter;
var Link = Router.Link;

var ChooseBottles = React.createClass({
    chooseBottle: function (id, e) {
        e.preventDefault();
        console.log(id);
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.chooseBottle.bind(this, 1)}
                            >House
                        </button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.chooseBottle.bind(this, 2)}
                            >Reserve
                        </button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.chooseBottle.bind(this, 3)}
                            >Fine
                        </button>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <button
                            className="btn btn-primary"
                            onClick={this.chooseBottle.bind(this, 4)}
                            >Cellar
                        </button>
                    </div>
                </div>
            </div>
        );
    }
});