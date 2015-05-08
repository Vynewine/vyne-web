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

                <Route name="match-by" handler={MatchByContainer}>
                    <DefaultRoute handler={MatchBy.Options}/>

                    /**
                    * Matching by Food
                    */

                    <Route name="match-by-food" path="/match-by/food" handler={MatchByFoodContainer}>
                        <DefaultRoute handler={MatchByFood.Category}/>
                        <Route name="match-by-food-type" path="type/:foodCategoryId" handler={MatchByFood.Type}/>
                        <Route name="match-by-food-preparation" path="preparation/:foodId"
                               handler={MatchByFood.Preparation}/>
                        <Route name="match-by-food-review" path="/match-by/food/review" handler={MatchByFood.Review}/>
                    </Route>

                    /**
                    * Matching by Occasion
                    */

                    <Route name="match-by-occasion" path="/match-by/occasion" handler={MatchByOccasionContainer}>
                        <DefaultRoute handler={MatchByOccasion.Occasions}/>
                        <Route name="match-by-occasion-select-type" path="/match-by/occasion/select-wine-type"
                               handler={MatchByOccasion.WineTypes}/>
                    </Route>

                    /**
                    * Matching by Specific Wine
                    */

                    <Route name="match-by-specific-wine" path="/match-by/specific-wine" handler={MatchBySpecificWine}/>
                </Route>


                /**
                * Cart Review
                */

                <Route name="cart-review" path="/cart-review" handler={CartReviewContainer}/>

                /**
                * User Account
                */

                <Route name="account" path="/account" handler={Account}>
                    <DefaultRoute handler={Account.Register}/>
                    <Route name="account-register" path="/account/register" handler={Account.Register}/>
                    <Route name="account-login" path="/account/login" handler={Account.Login}/>
                </Route>

                /**
                * Address Confirmation
                */

                <Route name="address" path="/address" handler={Address}/>

                /**
                * Payment
                */

                <Route name="payment" path="/payment" handler={Payment}/>
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