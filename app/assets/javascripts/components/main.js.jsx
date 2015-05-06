var Main = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    componentDidMount: function () {

    },
    render: function () {
        var name = this.context.router.getCurrentPath();
        return (
            <div>

                <div className="row">
                    <div className="col-xs-12">
                        <Link to="check-postcode" params={{postcode: "123"}}>Check Postcode</Link>
                        <Link to="choose-bottles">Choose Bottles</Link>
                        <Link to="match-by">Match By</Link>
                    </div>
                </div>

                <div className="row">
                    <div className="col-xs-12">
                        <span>{this.props.errors}</span>
                    </div>
                </div>

                <TimeoutTransitionGroup component="div"
                                        enterTimeout={500}
                                        leaveTimeout={500}
                                        transitionLeave={false}
                                        transitionName="example">
                    <Router.RouteHandler key={name}/>
                </TimeoutTransitionGroup>
            </div>
        );
    }
});

var MainContainer = Marty.createContainer(Main, {
    listenTo: [ErrorsStore],
    fetch: {
        errors() {
            return ErrorsStore.errors();
        }
    }
});