var Router = ReactRouter;


var Main = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    render: function () {
        var name = this.context.router.getCurrentPath();
        return (
            <div>
                This is main
                <Link to="check-postcode" params={{postcode: "123"}}>Check Postcode</Link>
                <Link to="choose-bottles">Choose Bottles</Link>
                <Link to="match-by">Match By</Link>

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