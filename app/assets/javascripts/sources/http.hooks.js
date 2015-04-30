Marty.HttpStateSource.addHook({
    priority: 1,
    before: function (req) {
        req.headers['X-CSRF-Token'] = $('meta[name="csrf-token"]').last().attr('content');
    }
});