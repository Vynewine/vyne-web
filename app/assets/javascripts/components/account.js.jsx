Account = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    render: function () {
        var name = this.context.router.getCurrentPath();
        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">
                        Register / Login
                        <Router.RouteHandler key={name}/>
                    </div>
                </div>
            </div>
        );
    }
});

Account.Register = React.createClass({
    handleRegister: function(e) {
        e.preventDefault();
        VyneRouter.transitionTo('address');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">

                        <button
                            className="btn btn-primary"
                            onClick={this.handleRegister}
                            >Register
                        </button>
                    </div>
                </div>
            </div>
        );
    }
});

Account.Login = React.createClass({
    handleLogin: function(e) {
        e.preventDefault();
        VyneRouter.transitionTo('address');
    },
    render: function () {
        return (
            <div>
                <div className="row">
                    <div className="col-sm-12">

                        <button
                            className="btn btn-primary"
                            onClick={this.handleLogin}
                            >Login
                        </button>
                    </div>
                </div>
            </div>
        );
    }
});