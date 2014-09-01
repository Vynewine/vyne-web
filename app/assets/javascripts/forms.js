// Fades in and out the different register steps
var formStepSetup = function() {
    var formSteps = $('.form-step')
    // console.log(formSteps);
    formSteps.each(function() {
        var $buttonNext = $(this).find( "a.btn-next" );
        var $buttonDone = $(this).find( "input[type=submit]" );
        console.log($buttonDone);
        $buttonNext.click(function(e){
            e.preventDefault();
            var parentStep = $(this).parents('.form-step');
            var nextStepName = $(this).data('nextStep');
            var nextStep = $("."+nextStepName);
            // console.log(parentStep);
            // console.log(nextStep);
            parentStep.fadeOut(function(){
                nextStep.fadeIn();
            });
        });
        //5 char
        $('#clientPostCode').keyup(function(e){
            var postcode = $(this).val();
            $buttonDone.attr('disabled','disabled');
            $buttonDone.addClass('disabled');
            if (postcode.length < 5) {
                $('.address-message').hide();
                $('#address_holder').hide();
            } else {
                console.log('postcode is ' + postcode);
                var mapUtil = new MapUtility();
                var coordinates = mapUtil.locateAndDo(postcode, function(data) {
                    if (data.error_message) {
                        console.error("Geocode API error: ", data.error_message);
                    } else {
                        var distance = mapUtil.calculateDistancesFor(data.results[0].geometry.location.lng, data.results[0].geometry.location.lat);
                        var guessedAddress = data.results[0].formatted_address;
                        if (guessedAddress == "London, UK") {
                            $('.address-message>p').html("Unknown address, please try again.");
                            $('.address-message').fadeIn();
                        } else {
                            console.log('distance is ' + distance + ' km');
                            console.log('distance is ' + mapUtil.kmToMile(distance) + ' miles');
                            $('#address_holder').html(guessedAddress);
                            $('#address_holder').fadeIn();
                            if (mapUtil.kmToMile(distance) < 5) {
                                $('.address-message>p').html("VYNZ delivers to this area.");
                                $buttonDone.removeAttr('disabled');
                                $buttonDone.removeClass('disabled');
                            } else {
                                $('.address-message>p').html("VYNZ does NOT deliver to this area!");
                            }
                            $('.address-message').fadeIn();
                        }
                    }
                });
            }
        });
        $buttonDone.click(function(e){
            e.preventDefault();
        });
    });
};