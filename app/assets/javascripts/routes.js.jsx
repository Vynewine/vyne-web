var Router = ReactRouter;
var Route = Router.Route;
var DefaultRoute = Router.DefaultRoute;
var Link = Router.Link;

var renderApp = function () {
    if ($('#new-app').length) {
        var routes = (
            <Route name="app" path="/" handler={Main}>
                <DefaultRoute handler={CheckPostcodeNew}/>
                <Route name="check-postcode" handler={CheckPostcodeNew}/>
                <Route name="check-availability" path="/check-availability/:postcode" handler={CheckAvailability}/>
                <Route name="choose-bottles" handler={ChooseBottles}/>
                <Route name="match-by" handler={MatchBy}/>
            </Route>
        );

        Router.run(routes, function (Handler) {
            React.render(<Handler/>, document.getElementById('new-app'));
        });
    }
};

$(document).on('page:load', renderApp);
$(document).ready(renderApp);