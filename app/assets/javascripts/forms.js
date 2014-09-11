// Part 1: Sign up process

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


// Part 2: Order creation:

function stripeResponseHandler(status, response) {
  var $form = $('#order-form');

  if (response.error) {
    // Show the errors on the form
    console.error(response.error.message);
    // $form.find('.payment-errors').text(response.error.message);
    $form.find('input[type="submit"]').prop('disabled', false);
  } else {
    // response contains id and card, which contains additional card details
    var token = response.id;
    // Insert the token into the form so it gets submitted to the server
    $form.append($('<input type="text" name="stripeToken" />').val(token));
    // and submit
    $form.get(0).submit();
  }
};

/**
 * Class that gives support for card information.
 */
function CardUtilities() {}
    /**
     * Static function to validate card number.
     */
    CardUtilities.validateCard = function(cardNumber) {
        var digits = cardNumber.split('');
        var sum = 0;
        for (var i = 0; i < digits.length; i++) {
            if (i%2===0) { // 0 2 4 ...
                sum += parseInt(digits[i]) * 2;
            } else { // 1 3 5 ...
                sum += parseInt(digits[i]);
            }
        }
        return sum % 10 === 0;
    };
    /**
     * Static function to find brand of a card based on its number.
     * http://stackoverflow.com/questions/72768/how-do-you-detect-credit-card-type-based-on-number
     */
    CardUtilities.identifyCardBrand = function(cardNumber) {
        cardNumber = cardNumber.split(' ').join('');
        // if (CardUtilities.validateCard(cardNumber) === false) return -1;
        var patterns = [
            // Visa card numbers start with a 4.
            /^4[0-9]{6,}$/,
            // MasterCard numbers start with the numbers 51 through 55, but this will only detect MasterCard credit cards;
            /^5[1-5][0-9]{5,}$/,
            // American Express card numbers start with 34 or 37.
            /^3[47][0-9]{5,}$/,
            // Discover card numbers begin with 6011 or 65.
            /^6(?:011|5[0-9]{2})[0-9]{3,}$/,
            // Diners Club card numbers begin with 300 through 305, 36 or 38.
            // There are Diners Club cards that begin with 5 and have 16 digits.
            // These are a joint venture between Diners Club and MasterCard, and should be processed like a MasterCard.
            /^3(?:0[0-5]|[68][0-9])[0-9]{4,}$/,
            // JCB cards begin with 2131, 1800 or 35.
            /^(?:2131|1800|35[0-9]{3})[0-9]{3,}$/
        ];
        for (var i = 0; i < patterns.length; i++) {
            if (patterns[i].test(cardNumber)) {
                return i+1;
            }
        }
        return 0;
    };

$(document).ready(function(){

    /**
     * Field masks:
     */
    $('#pmnm').mask('9999 9999 9999 99?99',{placeholder:" "});
    $('#pmxp').mask('99/99');

    /**
     * Hides or updates relevant field according to list selection.
     */
    $('#orderAddress').change(function() {
        var value = $(this).val();
        var $addrFields = $('#new_delivery_address');
        if (parseInt(value) === -1) {
            $('#old-address').val(0);
            $addrFields.fadeIn();
        } else {
            $('#old-address').val(value);
            $addrFields.fadeOut();
        }
    });

    /**
     * Hides or updates relevant field according to list selection.
     */
    $('#orderCard').change(function() {
        var value = $(this).val();
        var $addrFields = $('#new_card');
        if (parseInt(value) === -1) {
            $('#old-card').val(0);
            $addrFields.fadeIn();
        } else {
            $('#old-card').val(value);
            $addrFields.fadeOut();
        }
    });

    /**
     * Submits form.
     */
    $('#order-form').submit(function(event) {
        // Stops submiting:
        event.preventDefault();
        // Disables send button:
        var $form = $(this);
        $form.find('input[type="submit"]').prop('disabled', true);
        // Submits form if there is an old card entry,
        // Creates Stripe token if there is a new card entry.
        if ($('#old-card').val() !== '0') {
            $form.get(0).submit();
        } else {
            Stripe.card.createToken($form, stripeResponseHandler);
        }
    });

    /**
     * Parses card number, finds brand and updates relevant fields.
     */
    $('#pmnm').keyup(function(){
        var $card = $(this);
        var cardNumber = $card.val().replace(/[\s|_]/g, "");
        var brandId = CardUtilities.identifyCardBrand(cardNumber);
        $('#new-brand').val(brandId);
        if (brandId === 3 ) // Amex
            $('#new-card').val(cardNumber.substr(-5));
        else
            $('#new-card').val(cardNumber.substr(-4));
    });

    /**
     * Parses card expirity and updates relevant fields.
     */
    $('#pmxp').keyup(function(){
        var $exp = $(this);
        if ($exp.val().length === 5) {
            var v = $exp.val().split('/');
            $('#expm').val(v[0].substr(0,2));
            $('#expy').val(v[1].substr(0,2));
        }
    });


});




