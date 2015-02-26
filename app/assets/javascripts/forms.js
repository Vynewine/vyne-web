if ($('body.shop').length) {
    $('#filterPostcode').keyup(function (e) {
        var postcode = $(this).val().toUpperCase().trim();
        var $feedback = $('#filterPostcodeMessage');
        var $addressList = $('#order-address');
        var $postcodeField = $('#addr-pc');
        var $newAddressBlock = $('#new_delivery_address');
        $newAddressBlock.show();
        $addressList.val(-1);
        $postcodeField.val(postcode);
        $postcodeField.keyup();
    });

// Part 2: Order creation:

    function stripeResponseHandler(status, response) {
        var $form = $('#order-form');

        if (response.error) {
            var $errorList = $('#payment-errors');
            $errorList.empty().show();
            $errorList.append('<li>' + response.error.message + '</li>');
            $form.find('input[type="submit"]').prop('disabled', false);

            analytics.track('Stripe token response', {
                successfull: false,
                error: response.error.message
            });

        } else {
            var token = response.id;
            $('#stripe-token').val(token);

            analytics.track('Stripe toekn response', {
                successfull: true
            });

            processFinalOrderSubmit();
        }
    }

    /**
     * Class that gives support for card information.
     */
    function CardUtilities() {
    }

    /**
     * Static function to validate card number.
     */
    CardUtilities.validateCard = function (cardNumber) {
        var digits = cardNumber.split('');
        var sum = 0;
        for (var i = 0; i < digits.length; i++) {
            if (i % 2 === 0) { // 0 2 4 ...
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
    CardUtilities.identifyCardBrand = function (cardNumber) {
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
                return i + 1;
            }
        }
        return 0;
    };

    $(document).ready(function () {

        /**
         * Category (bottle) selection actions:
         */
        $('.bottle-list>li>a').click(function (e) {
            e.preventDefault();
            var $this = $(this);
            var $category = $('#category');
            var id = $this.data('categoryId');
            $('.category-details').hide();
            $('.category-details.category-' + id).fadeIn();
            $category.val(id);
        });
        $('.category-details .icon').click(function (e) {
            e.preventDefault();
            $(this).parent().fadeOut();
        });
        $('.category-details>div>a.next-step').click(function (e) {
            e.preventDefault();
            $(this).parent().parent().fadeOut();
        });


        /**
         * Field masks:
         */
        $('#pmnm').mask('9999 9999 9999 99?99', {placeholder: " "});
        $('#pmxp').mask('99/99');

        /**
         * Hides or updates relevant field according to list selection.
         */
        $('#order-address').change(function () {
            var value = $(this).val();
            var $addrFields = $('#new_delivery_address');
            var initialPostCode = $('#addr-pc').val();
            if (parseInt(value) === -1) {
                $('#address-id').val(0);
                $addrFields.fadeIn();
                $('#order-address:selected').removeAttr("selected");
                postCodeLookup(initialPostCode);
                $('#new-address').val(true);
                $('#addr-line-1').val('');
            } else {
                $('#address-id').val(value);
                $addrFields.fadeOut();
                $('#new-address').val(false);
                $('#addr-line-1').val('');
            }
        });

        /**
         * Hides or updates relevant field according to list selection.
         */
        $('#orderCard').change(function () {
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
        $('#order-form').submit(function (event) {
            // Stops submiting:
            event.preventDefault();
            // Disables send button:
            var $form = $(this);
            $form.find('input[type="submit"]').prop('disabled', true);
            // Submits form if there is an old card entry,
            // Creates Stripe token if there is a new card entry.
            var oldCard = $('#old-card');
            if (oldCard.val() !== '0' && oldCard.val() !== '') {
                analytics.track('Order placed', {
                    card: 'Old card'
                });

                processFinalOrderSubmit();
            } else {
                analytics.track('Order placed', {
                    card: 'New card'
                });

                Stripe.card.createToken($form, stripeResponseHandler);
            }
        });

        /**
         * Parses card number, finds brand and updates relevant fields.
         */
        $('#pmnm').keyup(function () {
            var $card = $(this);
            var cardNumber = $card.val().replace(/[\s|_]/g, "");
            var brandId = CardUtilities.identifyCardBrand(cardNumber);
            $('#new-brand').val(brandId);
            if (brandId === 3) // Amex
                $('#new-card').val(cardNumber.substr(-5));
            else
                $('#new-card').val(cardNumber.substr(-4));
        });

        /**
         * Parses card expirity and updates relevant fields.
         */
        $('#pmxp').keyup(function () {
            var $exp = $(this);
            if ($exp.val().length === 5) {
                var v = $exp.val().split('/');
                $('#expm').val(v[0].substr(0, 2));
                $('#expy').val(v[1].substr(0, 2));
            }
        });

        var orderCard = $('#orderCard');
        if ($('body').hasClass('logged-in') && orderCard.find("option").length > 1) {
            $('#new_card').hide();

            if (orderCard.find("option:selected").val() !== "" && orderCard.find("option:selected").val() !== "-1") {
                $('#old-card').val(orderCard.find("option:selected").val());
            }
        }

    });

    /**
     * Final order submission.
     */

    var processFinalOrderSubmit = function () {

        var old_card = $('#old-card').val();
        var new_card = $('#new-card').val();
        var new_brand = $('#new-brand').val();
        var expm = $('#expm').val();
        var expy = $('#expy').val();
        var warehouse_id = $('#warehouse_id').val();
        var wines = $('input[name="wines"]').val();
        var address_id = $('#address-id').val();
        var stripe_token = $('#stripe-token').val();
        var $errorList = $('#payment-errors');
        var slot_date = $('#slot_date').val();
        var slot_from = $('#slot_from').val();
        var slot_to = $('#slot_to').val();

        $.ajax({
            type: "POST",
            beforeSend: function (xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))
            },
            url: '/shop/create',
            data: {
                old_card: old_card,
                new_card: new_card,
                new_brand: new_brand,
                expm: expm,
                expy: expy,
                warehouse_id: warehouse_id,
                wines: wines,
                address_id: address_id,
                stripe_token: stripe_token,
                slot_date: slot_date,
                slot_from: slot_from,
                slot_to: slot_to
            },
            error: function (data) {

                $errorList.empty().show();

                if (data.responseJSON) {
                    var errors = data.responseJSON;
                    if (errors) {
                        errors.forEach(function (error) {
                            $errorList.append('<li>' + error + '</li>');
                        });
                    }

                    analytics.track('Error while creating order', {
                        status: 'error',
                        errors: errors.join(', ')
                    });

                } else {
                    if (data.status && data.statusText)
                        analytics.track('Error while creating order', {
                            status: data.status,
                            errors: data.statusText
                        });

                    $errorList.append('<li>We apologise. There was a server error.</li>');
                }

                $('#submit-order').prop('disabled', false);

            },
            success: function (data) {

                $errorList.empty().hide();

                analytics.track('Order successfully created', {
                    order_id: data.id
                });

                $.cookie('wines', '[]');

                window.location.replace('/orders/' + data.id);
            }
        });
    };

    $(window).load(function (e) {
        $('#filterPostcode').keyup();
        $('.noSwipingClass').show();
    });
}





