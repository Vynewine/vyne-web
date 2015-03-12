var sessionJsReady = function () {
    if ($('body.registrations.new').length) {
        $('#new_user').submit(function (e) {
            e.preventDefault();

            if ($('#user_mobile').val().trim() === '') {
                $('#mobile-error').show();
            } else {
                $('#mobile-error').hide();
                this.submit();
            }
        });
    }
};

$(document).ready(sessionJsReady);
$(document).on('page:load', sessionJsReady);