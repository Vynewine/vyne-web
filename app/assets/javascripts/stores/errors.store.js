var ErrorsStore = Marty.createStore({
    id: 'ErrorsStore',
    handlers: {
        setErrors: ErrorConstants.SET_ERRORS
    },
    getInitialState: function () {

        return {
            errors: []
        };
    },
    errors: function() {
        return this.state['errors'];
    },
    setErrors: function (errors) {
        this.state['errors'] = errors;
        this.hasChanged();
    }
});