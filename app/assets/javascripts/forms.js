// Fades in and out the different register steps
var formStepSetup = function() {
    var formSteps = $('.form-step');
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
                // console.log('postcode is ' + postcode);
                var mapUtil = new MapUtility();
                mapUtil.findCoordinatesAndExecute(postcode, function(coordinates) {
                    console.log('coordinates:', coordinates);
                    mapUtil.calculateDistancesForAllWarehouses(coordinates.lng, coordinates.lat, function(deliverable) {
                        console.log('delivers here?', deliverable);
                        if (deliverable) {
                            $('.address-message>p').html("VYNZ delivers to this area.");
                            $buttonDone.removeAttr('disabled');
                            $buttonDone.removeClass('disabled');
                        } else {
                            $('.address-message>p').html("VYNZ does NOT deliver to this area!");
                        }
                        $('.address-message').fadeIn();
                    });
                },
                function() {
                    console.error("Address error: unknown address");
                    $('.address-message>p').html("Unknown address, please try again.");
                    $('.address-message').fadeIn();
                });
                // Fails: SE3 9RQ
                // Succeeds: W6 9HH
                // Warehouse 1: SW65HU
                // Warehouse 2: E62JT
            }
        });
        // $buttonDone.click(function(e){
        //     e.preventDefault();
        // });
    });
};

$(document).ready(function(){
    $('#orderAddress').change(function() {
        var value = $(this).val();
        var $addrFields = $('#new_address_fields');
        if (parseInt(value) === -1) {
            $addrFields.fadeIn();
        } else {
            $addrFields.fadeOut();
        }
    });  
});




