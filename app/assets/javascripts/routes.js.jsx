var Route = ReactRouter.Route;
var DefaultRoute = ReactRouter.DefaultRoute;

var renderApp = function () {
    if ($('#new-app').length) {
        var routes = (
            <Route name="app" path="/" handler={Main}>
                <DefaultRoute handler={ChooseBottles}/>
            </Route>
        );

        ReactRouter.run(routes, function (Handler) {
            React.render(<Handler/>, document.getElementById('new-app'));
        });
    }
};


$(document).on('page:load', renderApp);
$(document).ready(renderApp);