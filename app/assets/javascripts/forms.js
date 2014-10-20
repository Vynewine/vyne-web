var updatePostcode = function(e){
    var postcode = $(this).val();
    // $buttonDone.attr('disabled','disabled');
    // $buttonDone.addClass('disabled');
    console.log('updating');
    console.log($('#filterPostcodeMessage'));
    if (postcode.length < 5) {
        $('#filterPostcodeMessage').html('');
    } else {
        // console.log('postcode is ' + postcode);
        var mapUtil = new MapUtility();
        mapUtil.findCoordinatesAndExecute(postcode, function(coordinates) {
            console.log('coordinates:', coordinates);
            mapUtil.calculateDistancesForAllWarehouses(coordinates.lng, coordinates.lat, function(deliverable) {
                console.log('delivers here?', deliverable);
                if (deliverable) {
                    $('#filterPostcodeMessage').removeClass('error');
                    $('#filterPostcodeMessage').html("VYNZ delivers to this area.");
                    // $buttonDone.removeAttr('disabled');
                    // $buttonDone.removeClass('disabled');
                } else {
                    $('#filterPostcodeMessage').addClass('error');
                    $('#filterPostcodeMessage').html("VYNZ does NOT deliver to this area!");
                }
                $('#filterPostcodeMessage').fadeIn();
            });
        },
        function() {
            console.error("Address error: unknown address");
            $('#filterPostcodeMessage').html("Unknown address, please try again.");
            $('#filterPostcodeMessage').fadeIn();
        });
        // Fails: SE3 9RQ
        // Succeeds: W6 9HH
        // Warehouse 1: SW65HU
        // Warehouse 2: E62JT
    }
};

$('#filterPostcode').keyup(function(e){
    var postcode = $(this).val();
    var $feedback = $('#filterPostcodeMessage');
    var $addressList = $('#order-address');
    var $postcodeField = $('#addr-pc');
    var $newAddressBlock = $('#new_delivery_address');
    $newAddressBlock.show();
    $addressList.val(-1);
    $postcodeField.val(postcode);
    $postcodeField.keyup();
    // updatePostcode();
});

$('.clientPostCode').keyup(updatePostcode);

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
     * Category (bottle) selection actions:
     */
    $('.bottle-list>li>a').click(function(e) {
        e.preventDefault();
        var $this = $(this);
        var $category = $('#category');
        var id = $this.data('categoryId');
        console.log('clicked', id);
        $('.category-details').hide();
        $('.category-details.category-'+id).fadeIn();
        $category.val(id);
    });
    $('.category-details .icon').click(function(e) {
        e.preventDefault();
        $(this).parent().fadeOut();
    });
    $('.category-details>div>a.next-step').click(function(e) {
        e.preventDefault();
        $(this).parent().parent().fadeOut();
    });

    /**
     * Check postcode delivery possibilities:
     */
    $('#addr-pc').keyup(function(e){

        var postcode = $(this).val().toUpperCase().replace(/[^A-Z0-9]/g, "");

        // Fields:
        var $street = $('#addr-st');
        var $detail = $('#addr-no');

        // Postcode sliable panel
        var $slideable = $('#postcode-panel .slideable');

        // Feedback area:
        var $feedback = $('#filterPostcodeMessage');

        //Not available
        var $notavailable = $('.not-available');

        if (postcode.length < 5) {
            // Empty fields:
            $street.val('');
            $detail.val('');
            // Disable fields:
            $street.attr('disabled','disabled');
            $detail.attr('disabled','disabled');
            // Feedback from beginning:
            $feedback.html('');
            $feedback.css({ 'display': 'none'});
            $('#use-postcode').css({ 'display': 'none'});
        } else {

            var mapUtil = new MapUtility();

            mapUtil.calculateDistanceForAllWarehouses(postcode, function(delivery) {
                // console.log('callback 1', deliverable);
                if (delivery.available) {

                    $slideable.removeClass('slide-up');

                    $notavailable.hide();

                    $feedback.css({ 'display': 'block '});
                    $('#use-postcode').css({ 'display': 'inline-block '});

                    $feedback.removeClass('error');
                    $feedback.html("VYNZ delivers to this area.");

                    $('#warehouses').val(delivery.warehouses);

                    var initialPostCode = $('#filterPostcode').val().toUpperCase().replace(/[^A-Z0-9]/g, "");

                    //Preselect existing address for logged-in users
                    var existingAddresses = $('#order-address').find('option');
                    if(existingAddresses.length > 2) {
                        var foundSavedAddress = false;
                        existingAddresses.filter(function () {
                            if ($(this).text().match(initialPostCode) && !foundSavedAddress) {
                                foundSavedAddress = true;
                                $('#address-id').val($(this).val());
                                $('#new_delivery_address').fadeOut();
                                return true;
                            }
                        }).prop('selected', true);

                        if (!foundSavedAddress) {
                            postCodeLookup(initialPostCode);
                        }
                    } else {
                        $('#order-address').hide();
                        //Pre-fill addresses available for that postcode
                        postCodeLookup(initialPostCode);
                    }

                    // Google API cannot find the street name based on the postcode!
                    // This is why we must first find the damn longitude and latitude first.
                    // So this is a 2-step process, don't be alarmed.

                    /**
                     * Callback for when the coordinates are returned from Google.
                     * This will request a geocode lookup to fetch the address.
                     */
                    var successCallback = function(coordinates) {
                        // console.log('okie', coordinates.lng, coordinates.lat);

                        var geocoder = new google.maps.Geocoder();
                        var latlng = new google.maps.LatLng(coordinates.lat, coordinates.lng);
                        
                        /**
                         * Formats readable address and updates interface.
                         */
                        var successAddressCallback = function(results, status) {
                            if (status == google.maps.GeocoderStatus.OK) {
                                // console.log(results[0].formatted_address);
                                var fullAddress = results[0].formatted_address;
                                var simpleAddress = fullAddress.split(',')[0];
                                var street = simpleAddress.replace(/[\d]+\s/, "");
                                var detail = simpleAddress.match(/[\d]+/)[0];
                                $street.removeAttr('disabled');
                                $detail.removeAttr('disabled');
                            } else {
                                console.error("Geocode was not successful for the following reason: " + status);
                            }
                        };

                        // Address lookup:
                        geocoder.geocode( { 'latLng': latlng}, successAddressCallback);
                    };

                    /**
                     * Error callback method for the coordinates lookup.
                     * The postcode is already considered to be "deliverable", so it enables the fields anyway.
                     */
                    var errorCallback = function() {
                        console.error('Could not find coordinates for this postcode!');
                        $street.removeAttr('disabled');
                        $detail.removeAttr('disabled');
                        $feedback.html("Unknown address, please try again.");
                    };

                    // Coordinates lookup:
                    mapUtil.findCoordinatesAndExecute(postcode, successCallback, errorCallback);

                } else {
                    $slideable.addClass('slide-up');
                    $notavailable.show();
                    $feedback.hide().addClass('error');
                    $feedback.html("VYNZ does NOT deliver to this area!");
                    $('#use-postcode').css({ 'display': 'none'});
                }
            });
        }
    });

    /**
     * Field masks:
     */
    $('#pmnm').mask('9999 9999 9999 99?99',{placeholder:" "});
    $('#pmxp').mask('99/99');

    /**
     * Hides or updates relevant field according to list selection.
     */
    $('#order-address').change(function() {
        var value = $(this).val();
        var $addrFields = $('#new_delivery_address');
        if (parseInt(value) === -1) {
            $('#address-id').val(0);
            $addrFields.fadeIn();
            postCodeLookup(initialPostCode);
        } else {
            $('#address-id').val(value);
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

    /**
     * Lookup valid addresses for a post code
     */
    var postCodeLookup = function(postcode) {

        var $street = $('#addr-st');

        $.getJSON("http://services.postcodeanywhere.co.uk/PostcodeAnywhere/Interactive/Find/v1.10/json3.ws?callback=?",
            {
                Key: 'EC89-AH81-AF29-TX89',
                SearchTerm: postcode,
                PreferredLanguage: 'English',
                Filter: 'None',
                UserName: ''
            },
            function (data) {
                if (data.Items.length == 1 && typeof(data.Items[0].Error) != "undefined") {
                    console.log(data.Items[0].Description);
                } else {
                    if (data.Items.length == 0) {
                        console.log("Sorry, there were no results");
                    } else {
                        console.log(data.Items);

                        $.each(data.Items, function (key, value) {
                            $('#suggested-addresses')
                                .append($("<option></option>")
                                    .attr("value", value.StreetAddress)
                                    .text(value.StreetAddress));
                        });

                        $('#suggested-addresses').change(function() {
                            $( "#suggested-addresses").find("option:selected").each(function() {
                                if(this.value !== '0') {
                                    $street.val($(this).text());
                                } else {
                                    $street.val('');
                                }
                            });
                        });
                    }
                }
            });
    }

});

$(window).load(function(e) {
    $('#filterPostcode').keyup();
});



