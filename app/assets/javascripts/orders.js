var requestSubstitution;
var interval;

var setCountDown = function (time) {
    if (time > 0) {
        var minutes = Math.floor(time / 60);
        var seconds = time - minutes * 60;
        var minuteText = '00';

        setInterval(function () {
            $('#counter-text').fadeIn('slow');
        }, 1000);

        interval = setInterval(function () {
            var counter = $('#counter');
            if (seconds == 0) {
                if (minutes == 0) {
                    clearInterval(interval);
                    location.reload();
                    return;
                } else {
                    minutes--;
                    seconds = 60;
                }
            }
            if (minutes > 0) {
                 minuteText = minutes < 10 ? '0' + minutes : minutes;
            } else {
                minuteText = '00';
            }
            var secondText = seconds < 10 ? '0' + seconds : seconds;
            counter.html(minuteText + ':' + secondText);
            seconds--;
        }, 1000);
    }
};

var ordersJsReady = function () {

    if(interval) {
        clearInterval(interval);
    }

    if ($('body.orders').length && $('#substitutions-section').length) {

        setCountDown(orderChangeTimeOutSeconds);

        var substitutions = [];

        requestSubstitution = function(itemId) {

            $('#error').hide();
            $('#substitution-reason-' + itemId).toggle();
            var $link = $('#request-' + itemId);
            if ($link.val() === 'Change') {
                substitutions.push(itemId);
                $link.val('Cancel');
            } else {
                $link.val('Change');
                var index = $.inArray(itemId, substitutions);
                if (index > -1) {
                    $('#reason-error-' + itemId).hide();
                    substitutions.splice(index, 1);
                }
            }
        };

        $('#substitutions-form').submit(function (e) {

            var substitutionsAndReasons = [];
            var errors = [];

            e.preventDefault();
            $(substitutions).each(function () {
                var reason = $('#substitution-reason-' + this);

                if (reason.val().trim() === '') {
                    errors.push($('#reason-error-' + this));
                }

                substitutionsAndReasons.push({
                    id: this,
                    reason: reason.val()
                });
            });

            if (errors.length > 0) {
                $.each(errors, function () {
                    this.show();
                });

            } else if (substitutions.length === 0) {
                $('#error').show();
            }
            else {
                $('#substitutions').val(JSON.stringify(substitutionsAndReasons))
                this.submit();
            }
        });
    }

    if ($('body.orders').length && $('#cancellation-section').length) {

        setCountDown(orderChangeTimeOutSeconds);

        setInterval(function () {
            $('#counter-text').fadeIn('slow');
        }, 1000);

        $('#cancel-order').submit(function (e) {
            e.preventDefault();
            if ($('#reason').val().trim() === '') {
                $('#cancel-error').show();
            } else {
                this.submit();
            }
        });

    }

};

$(document).on('page:change', ordersJsReady);