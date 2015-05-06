var Router = ReactRouter;
var Route = Router.Route;
var DefaultRoute = Router.DefaultRoute;
var Link = Router.Link;
var VyneRouter;

var renderApp = function () {
    if ($('#new-app').length) {
        var routes = (
            <Route name="app" path="/" handler={MainContainer}>
                <DefaultRoute handler={CheckPostcodeNewContainer}/>
                <Route name="check-postcode" handler={CheckPostcodeNewContainer}/>
                <Route name="check-availability" path="/check-availability/" handler={CheckAvailabilityContainer}/>
                <Route name="choose-bottles" handler={ChooseBottlesContainer}/>
                <Route name="match-by" handler={MatchBy} />
                <Route name="match-by-food" path="/match-by/food" handler={MatchByFood}>
                    <DefaultRoute handler={MatchByFood.Category}/>
                    <Route name="match-by-food-category" path="/match-by/food/category" handler={MatchByFood.Category}/>
                    <Route name="match-by-food-type" path="/match-by/food/type" handler={MatchByFood.Type}/>
                    <Route name="match-by-food-preparation" path="/match-by/food/preparation" handler={MatchByFood.Preparation}/>
                </Route>
                <Route name="match-by-occasion" path="/match-by/occasion" handler={MatchByOccasion}/>
                <Route name="match-by-specific-wine" path="/match-by/specific-wine" handler={MatchBySpecificWine}/>
            </Route>
        );

        VyneRouter = Router.create({
            routes: routes
        });

        VyneRouter.run(function (Handler) {
            React.render(<Handler/>, document.getElementById('new-app'));
        });
    }
};

$(document).on('page:load', renderApp);
$(document).ready(renderApp);