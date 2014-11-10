// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require library
//= require map
//= require forms
//= require vendor/maskedinput
//= require vendor/swiper_min
//= require vendor/idangerous.swiper.hashnav

var ready = function () {
    // console.log('Doc is apparently ready');
    if (typeof(admin) !== 'undefined' && admin !== null && admin === true) {

    } else {

    }

};

events = [];

var wines = [];

var wine = function () {
    this.id;
    this.quantity = 0;
    this.category = 0;
    this.label = '';
    this.price = '';
    this.specificWine = '';
    this.food = [];
    this.occasion = 0;
    this.occasionName = '';
    this.wineType = { id: 0, name: '' };
    this.complete = false;
};

//Object to store food details
var food = function (id, name, preparationId, preparationName) {
    this.id = id;
    this.name = name;
    this.preparation = preparationId;
    this.preparationName = preparationName;
};

var wineCount = 0;
var secondBottle = false;


$(function () {

    /* iOS Check */
    if (navigator.userAgent.match(/(iPod|iPhone|iPad)/)) {
        $('.prefs-overview, .btn-checkout').addClass('ios');

        $('#preferences-panel').scroll(function (e) {
            $('.prefs-overview').css({ 'bottom': -$(this).scrollTop() });
        });

        $('#review-panel').scroll(function (e) {
            $('.btn-checkout').css({ 'bottom': -$(this).scrollTop() });
        });
    }

    /* Header */

    //Hamburger/menu icon animation classes
    $('.menu-link').click(function (e) {

        if ($('.menu-link').hasClass('slide')) {
            analytics.track('Menu', {
                action: 'Closed'
            });
        } else {
            analytics.track('Menu', {
                action: 'Opened'
            });
        }

        e.preventDefault();
        $('.menu-link').toggleClass('slide');
        $('.container').toggleClass('menu-visible');
        $('.aside-bar').toggleClass('visible');
    });

    //Clicking the cart link takes you to the review page
    $('.cart-link').click(function (e) {
        e.preventDefault();
        if ($('.order-table .order-bottle').length > 0) {
            cleanupUnfinishedWines();

            if (wineCount == 0) {
                $('.add-bottle').show();
            } else {
                $('.add-bottle').hide();
            }

            resetEventsForCart();

            order.swipeTo(3, 500, false);
            $('.btn-checkout').show();

        }

        analytics.track('Review order', {
            action: 'Cart link clicked',
            cart_count: $('.cart-count').text()
        });
    });

    var cleanupUnfinishedWines = function () {
        if (wines) {
            for (var i = 0; i < wines.length; i++) {
                if (!wines[i].complete) {
                    wines.splice(i, 1);
                    wineCount--;
                }
            }


        }
    };

    //When we're in the cart there are always 3 swiper events required to go back to the beginning of the flow.
    var resetEventsForCart = function () {
        events = [];
        for (var i = 0; i < 3; i++) {
            events.push({
                type: 'slideChange'
            });
        }
    };

    /* Walkthrough */

    //Initialising the walkthrough slider
    $('#walkthrough').swiper({
        mode: 'horizontal',
        speed: 200,
        pagination: '.pagination',
        paginationClickable: true
    });


    /* Order */

    //Initialising order slider
    var order = $('#order').swiper({
        mode: 'horizontal',
        speed: 200,
        //hashNav: true,
        noSwiping: true,
        simulateTouch: false,
        onlyExternal: true,
        onSlideChangeStart: function (swiper) {
            if (swiper.activeSlide()) {
                analytics.track('Slide changed', {
                    slide: swiper.activeSlide().id
                });

                if (swiper.activeSlide().id == 'delivery-panel') {
                    verifyAddress();
                }
            }

        },
        onSlideNext: function () {
            events.push({
                type: 'slideChange'
            });
        }
    });

    //A class for navigating to the next slide
    $('.next-slide').click(function (e) {
        e.preventDefault();
        order.swipeNext();
    });

    $('.back-nav').click(function (e) {
        e.preventDefault();
        var event = events.pop();
        if (event) {
            switch (event.type) {
                case 'slideChange':
                    if (event.name) {
                        order.swipeTo(event.name, 500);
                    } else {
                        order.swipePrev();
                    }
                    break;
                case 'matchingWine':
                    clearPreferences();
                    break;
                default:
                    console.log('Can\'t handle event:' + event.type);
            }
        }
    });


    /* Availabilty */

    //Get the postcode form the URL using query params
    try {
        var queryHash = getUrlVars();
        if (getUrlVars()["postcode"]) {
            $('#filterPostcode').val(getUrlVars()["postcode"].replace('+', ' '));
        } else {
            $('#initial-postcode-lookup').hide();
            $('#filterPostcode').show();
        }

    } catch (err) {
        console.log(err);
    }

    $('#order input').keypress(function (e) {
        if (e.which == 13) {
            e.preventDefault();
        }
    });

    /* Signup for mailing list */
    $('#sign-up-submit').click(function (e) {
        e.preventDefault();
        var email = $('#sign-up-email').val();
        var postcode = $('#filterPostcode').val();
        var $errorList = $('#sign-up-errors');
        var distances = $('#sign-up-distances').val();
        var closed = $('#sign-up-closed').val();
        var panel = $('#sign-up-panel-form');
        var panelThankYou = $('#sign-up-panel-thank-you');


        panel.hide();
        panelThankYou.addClass('loading');
        panelThankYou.show();

        $.ajax({
            type: "POST",
            beforeSend: function (xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))
            },
            url: '/signup/mailing_list_signup',
            data: {
                email: email,
                list_key: 'coming-soon',
                postcode: postcode,
                distances: distances,
                closed: closed
            },
            error: function (data) {

                if (data) {
                    var errors = data.responseJSON.errors;
                    if (errors) {
                        error = errors.join(', ');

                        $errorList.empty().show();
                        errors.forEach(function (error) {
                            $errorList.append('<li>' + error + '</li>');
                        });
                    }
                }

                panelThankYou.hide();
                panel.show();

            },
            success: function (data) {

                panelThankYou.removeClass('loading');
                panelThankYou.text('We\'ll be in touch...')

                $errorList.empty();
                $('#sign-up-panel-form').hide();
                $('#sign-up-panel-thank-you').show();
                analytics.track('User mailing list sing up', {
                    email: email
                });
            }
        });

    });


    /* Select a Bottle */

    //Display more infomation about a bottle on click
    $('.bottle-link').click(function (e) {
        if (!$('.close').hasClass('hover')) {
            $('.bottle-info').removeClass('active');
            $(this).parent().find('.bottle-info').addClass('active');
        }
        analytics.track('Bottle selected', {
            category: $(this).data('category-id')
        });
    });

    $('.order-panel-overlay').css({
        'height': $(this).parent().height() + 'px'
    });

    $('.close').hover(function () {
        $(this).addClass('hover');
    }, function () {
        $(this).removeClass('hover');
    });

    $('.close').click(function (e) {
        $('.bottle-info').removeClass('active');
    });

    $('.select-bottle').click(function (e) {
        e.preventDefault();
        $('.bottle-info').removeClass('active');

        if (secondBottle && wineCount == 0) {
            wineCount++;
        }

        //Create a new wine object
        wines[wineCount] = new wine();
        wines[wineCount].quantity = 1;
        wines[wineCount].label = $(this).parent().find('.label').text();
        wines[wineCount].price = $(this).parent().find('.price').text();
        wines[wineCount].category = $(this).closest('.bottle-info').data('category-id');

        analytics.track('Bottle chosen', {
            category: wines[wineCount].category
        });

        order.swipeNext();
    });


    /* Preferences */

    var ingredientCount, cartCount = 0;

    //Simple tab naviation
    $('.tab-list li a').click(function (e) {
        e.preventDefault();
        $($(this).attr('href')).parent().find('.tab').removeClass('active');
        $($(this).attr('href')).addClass('active');
        if ($(this).attr('href') == '#with-food') $('.prefs-overview').show();
    });

    $('.tab-list.tab-list__horizontal li a').click(function (e) {
        e.preventDefault();

        analytics.track('Matching wine', {
            type: $(this).attr('href').replace('#', '')
        });

        events.push({
            type: 'matchingWine',
            name: $(this).attr('href').replace('#', '')
        });
    });

    $('.back').click(function (e) {
        e.preventDefault();
        $('.tab.active').last().removeClass('active');
    });

    $(document).on('click', '.prefs-list li a', function (e) {
        e.preventDefault();
        $('.order-panel').scrollTop(0);

        if ($(this).closest('ul').attr('id') == 'occasion-list') {
            setOccasion(this);
        }

        analytics.track('Matching selected', {
            selection: $(this).parent().attr('id')
        });
    });

    var setFood = function () {

        clearFood();//??

        $('.prefs-overview-list li').each(function (i, el) {
            if (!$(this).hasClass('empty')) {
                wines[wineCount].food.push(
                    new food(
                        $(this).find('img').first().attr('id').split('-')[2],
                        $(this).find('.food-name').text(),
                        $(this).find('.prep-name').text(),
                        $(this).find('.prep-name-text').text()
                    )
                );
            }
        });

        wines[wineCount].complete = true;

        clearOccasion();
        clearSpecificWine()
    };

    var setOccasion = function (element) {

        wines[wineCount].occasion = $(element).parent().attr('id').split('-')[1];
        wines[wineCount].occasionName = $(element).find('span').text();

        wines[wineCount].complete = true;

        clearFood();
        clearSpecificWine();
    };

    var setSpecificWine = function (element) {

        wines[wineCount].specificWine = $('input[name="specific-wine"]').val();

        wines[wineCount].complete = true;

        clearFood();
        clearOccasion();
    };

    var clearFood = function () {
        if (wines[wineCount]) {
            wines[wineCount].food = [];
        }
    };

    var clearOccasion = function () {
        wines[wineCount].occasion = null;
        wines[wineCount].occasionName = null;
        wines[wineCount].wineType.id = 0;
        wines[wineCount].wineType.name = null;
    };

    var clearSpecificWine = function () {
        wines[wineCount].specificWine = null;
    };

    $(document).on('click', '.prefs-list-bottom li a', function (e) {
        e.preventDefault();

        var $this = $(this);
        var id = $this.parent().attr('id').split('-')[1];
        var name = $this.parent().find('span').text();

        if ($this.attr('href') == '#preparation') {
            parentid = $this.parent().attr('id').split('-')[1];
        }

        if (!$this.parent().hasClass('selected')) {

            if ($this.closest('.tab').attr('id') == 'preparation') {
                $img = $this.find('img').clone();
                var prepID = $this.closest('li').attr('id').split('-')[1];
                var prepName = $(this).find('span').text();
                $('#food-item-' + parentid).after($img.addClass('food-prep').attr('id', parentid));
                $('#food-item-' + parentid).closest('li').append($('<span/>', { text: prepID }).addClass('prep-name'));
                $('#food-item-' + parentid).closest('li').append($('<span/>', { text: prepName }).addClass('prep-name-text'));
            } else if ($this.closest('ul').attr('id') == 'wine-list') {
                //Add the food to the wine object
                wines[wineCount].wineType.id = id; //.split('-')[1];
                wines[wineCount].wineType.name = name;
            } else {
                //Add the food to our mini review bar at the bottom
                $img = $this.find('img').clone();
                $img.attr('id', 'food-item-' + id);
                $empty = $('.prefs-overview-list .empty').first();
                $empty.find('span').replaceWith($img);
                $empty.append($('<span/>', { text: name }).addClass('food-name')).removeClass('empty');

                $this.parent().addClass('selected');
            }

            if ($('.prefs-overview-list .empty').length == 0 && $this.attr('href') != '#preparation') $('.food-limit').show();

            $this.closest('.tab').removeClass('active');

            if ($this.closest('ul').attr('id') == 'wine-list') {
                //$('#select-preferences').click();
                order.swipeNext();
                createCartPage(wines, wineCount);
            }

        } else {
            $this.parent().removeClass('selected');
            $('#food-item-' + id).closest('li').addClass('empty').empty().append('<a href=""><span>+</span></a>');
            $('#food-' + $this.parent().attr('id')).removeClass('selected');
        }

    });

    $(document).on('click', '.prefs-overview-list li a', function (e) {
        e.preventDefault();
        $this = $(this);
        if ($this.hasClass('empty')) {
            $('prefs-list-bottom').closest('.tab').removeClass('active');
        } else {
            $foodid = $this.find('img').attr('id').split('-');
            $('#food-' + $foodid[2]).removeClass('selected');
            $('.food-limit').hide();
            $this.parent().addClass('empty').empty().append('<a href=""><span>+</span></a>');
        }
    });

    /***
     * Done with food or occasion preferences selection. Moving to order review.
     * */
    $('#select-preferences').click(function (e) {
        e.preventDefault();

        setFood();

        createCartPage(wines, wineCount);
    });

    /***
     * Done with specific wine selection. Moving to order review.
     * */
    $('#specific-wine').click(function (e) {
        e.preventDefault();

        if ($('input[name="specific-wine"]').val() != '') {
            setSpecificWine();

            analytics.track('Matching wine', {
                type: 'Specific wine',
                text: wines[wineCount].specificWine
            });

            createCartPage(wines, wineCount);
            $('#specific-wine-errors').empty().hide();
            order.swipeNext();
        } else {
            $('#specific-wine-errors').empty().show().append('<li>Please enter wine name</li>');
        }

    });

    $(document).on('click', '.order-table .delete', function (e) {
        e.preventDefault();
        $this = $(this);
        $this.closest('tr').remove();
        $bottle = $(this).closest('.order-bottle');

        var wineid = $this.closest('td').attr('id').split('-')[1];

        wines.splice(wineid, 1);

        if (wineCount > 0) {
            wineCount--;
        }

        if (!$('.order-bottle').length) {
            $('.no-bottles').show();
            $('.add-bottle').hide();
            resetEventsForEmptyCart();
        } else if ($('.order-bottle').length == 1) {
            $('.add-bottle').show();
        }

        if (!$bottle.find('.order-table-bottle-price').has('del').length) {
            $discountedBottle = $('.order-table-bottle-price del').closest('.order-bottle');
            $('.order-table-bottle-price del').remove();
            var diff = parseInt($discountedBottle.find('.order-table-bottle-price span').text().substr(1, 2)) + 5;
            $discountedBottle.find('.order-table-bottle-price span').text('£' + diff);
        }

        calculateTotalCost();

        analytics.track('Review order', {
            action: 'Remove bottle'
        });

    });

    $('.another-bottle').click(function (e) {
        e.preventDefault();
        secondBottle = true;
    });

    $('.add-bottle-link').click(function (e) {
        e.preventDefault();

        order.swipeTo(1, 500);
        $('.add-bottle, .btn-checkout').hide();

        if ($(this).closest('tr').hasClass('no-bottles')) {
            analytics.track('Review order', {
                action: 'Add a bottle'
            });
        } else {
            analytics.track('Review order', {
                action: 'Add another bottle'
            });
        }
    });

    $('.add-same-bottle-link').click(function (e) {
        e.preventDefault();
        wineCount++;
        wines[wineCount] = wines[wineCount - 1];
        createCartPage(wines, wineCount);
        $('.add-bottle').hide();

        analytics.track('Review order', {
            action: 'Add same bottle'
        });

    });


    $(document).on('click', '#account-link', function (e) {
        e.preventDefault();
        if ($('#account-form').hasClass('register-form')) {
            $('#account-form').removeClass().addClass('signin-form');
            $('.account-heading').text('Sign In');
            $('.account-message').html('Don\'t have an account? <a href="" id="account-link" class="register-link">Register</a>');
            $('input[name="user[first_name]"], input[name="user[last_name]"], input[name="user[mobile]"], input[name="user[password_confirmation]"]').hide();
        } else {
            $('#account-form').removeClass().addClass('register-form');
            $('.account-heading').text('Register');
            $('.account-message').html('Have an account? <a href="" id="account-link" class="signin-link">Sign In</a>');
            $('input[name="user[first_name]"], input[name="user[last_name]"], input[name="user[mobile]"], input[name="user[password_confirmation]"]').show();
        }
    });

    /* Delivery Details */

    $('#delivery-details').click(function (e) {

        e.preventDefault();

        var $orderCard = $('#orderCard');

        if ($('#account-form').hasClass('register-form')) {

            //Needs Validation
            var first_name = $('input[name="user[first_name]"]').val(),
                email = $('input[name="user[email]"]').val(),
                password = $('input[name="user[password]"]').val();

            var data = "user[first_name]=" + first_name + "&user[email]=" + email + "&user[password]=" + password;

            $.ajax({
                type: "POST",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))
                },
                url: '/signup/create',
                data: data,
                error: function (data) {
                    //Response
                    var error = '';
                    var errors = data.responseJSON.errors;
                    if (errors) {
                        error = errors.join(', ');
                        var $errorList = $('#sign-in-errors');
                        $errorList.empty().show();
                        errors.forEach(function (error) {
                            $errorList.append('<li>' + error + '</li>');
                        });
                    }

                },
                success: function (data) {
                    analytics.track('New user', {
                        name: first_name,
                        email: email
                    });

                    analytics.identify(data.id, {
                        name: data.first_name,
                        email: data.email
                    });

                    order.swipeNext();
                }
            });

        } else if ($('#account-form').hasClass('signin-form')) {
            //Needs Validation
            var email = $('input[name="user[email]"]').val();
            password = $('input[name="user[password]"]').val();

            var data = "&user[email]=" + email + "&user[password]=" + password;

            $.ajax({
                type: "POST",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))
                },
                url: '/users/sign_in.json',
                data: data,
                error: function (data) {
                    //TODO: Log this

                    var $errorList = $('#sign-in-errors');
                    $errorList.empty().show();
                    $errorList.append('<li>There was an error communicating with the server. Please try again.</li>');
                    console.log(data);
                },
                success: function (data) {
                    if (data.success) {
                        $('meta[name="csrf-token"]').last().prop("content", data.csrfToken);
                        $('input[name="authenticity_token"]').last().val(data.csrfToken);
                        var initialPostCode = $('#filterPostcode').val().toUpperCase().replace(/[^A-Z0-9]/g, "");
                        var foundSavedAddress = false;
                        var $select = $('#order-address');
                        if (data.addresses && data.addresses.length > 0) {
                            var addresses = data.addresses;
                            for (var i = 0; i < addresses.length; i++) {
                                var address = addresses[i];
                                var fullAddress = address.detail + ' ' + address.street + ' ' + address.postcode;

                                if (address.postcode.match(initialPostCode) && address.postcode.match(initialPostCode).length > 0 && !foundSavedAddress) {
                                    $select.append('<option value=' + address.id + ' selected="selected">' + fullAddress + '</option>');
                                    foundSavedAddress = true;
                                } else {
                                    $select.append('<option value=' + address.id + '>' + fullAddress + '</option>');
                                }
                            }
                            if (foundSavedAddress) {
                                $('#new_delivery_address').fadeOut();
                            }
                        }
                        if (data.payments && data.payments.length > 0) {
                            var payments = data.payments;

                            $('#new_card').hide();
                            for (var i = 0; i < payments.length; i++) {
                                var payment = payments[i];
                                var cardNumber;
                                if (payment.brand == 3) { // American Express
                                    cardNumber = '**** ****** ' + payment.number;
                                } else {
                                    cardNumber = '**** **** **** ' + payment.number;
                                }

                                if (i === 0) {
                                    $orderCard.append('<option value=' + payment.id + ' selected="selected">' + cardNumber + '</option>');
                                    $('#old-card').val(payment.id);
                                } else {
                                    $orderCard.append('<option value=' + payment.id + '>' + cardNumber + '</option>');
                                }
                            }
                        } else {

                        }

                        analytics.track('User sign in', {
                            status: 'successfull',
                            email: email
                        });

                        analytics.identify(data.user.id, {
                            name: data.user.first_name,
                            email: data.user.email
                        });

                        order.swipeNext();
                    } else {

                        var errors = data.errors;
                        if (errors) {
                            var $errorList = $('#sign-in-errors');
                            $errorList.empty().show();
                            errors.forEach(function (error) {
                                $errorList.append('<li>' + error + '</li>');
                            });
                        }

                        analytics.track('User sign in', {
                            status: 'error',
                            errors: errors.join(', '),
                            email: email
                        });
                    }

                }
            });
        }

    });


    /* Address Details */

    $('#address-details').click(function (e) {

        e.preventDefault();

        var address_s = $('#addr-st').val(),
            address_p = $('#addr-pc').val(),
            mobile = $('#mobile').val(),
            address_id = $('#address-id').val(),
            new_address = $('#new-address').val();

        var $errorList = $('#address-errors');

        $.ajax({
            type: "POST",
            beforeSend: function (xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))
            },
            url: '/signup/address',
            data: {
                address_s: address_s,
                address_p: address_p,
                mobile: mobile,
                address_id: address_id,
                new_address: new_address
            },
            error: function (data) {

                $errorList.empty().show();

                if (data.responseJSON) {
                    var errors = data.responseJSON.errors;
                    if (errors) {
                        errors.forEach(function (error) {
                            $errorList.append('<li>' + error + '</li>');
                        });
                    }

                    analytics.track('Address error', {
                        status: 'error',
                        errors: errors.join(', ')
                    });
                } else {
                    if (data.status && data.statusText)
                        analytics.track('Address error', {
                            status: data.status,
                            errors: data.statusText
                        });

                    $errorList.append('<li>We apologise. There was a server error.</li>');
                }

            },
            success: function (data) {

                $errorList.empty().hide();

                if (address_id !== '' && address_id !== '0') {
                    analytics.track('Address updated', {
                        address_street: address_s,
                        address_postcode: address_p,
                        mobile: mobile,
                        id: data.id
                    });
                } else {
                    analytics.track('Address created', {
                        address_street: address_s,
                        address_postcode: address_p,
                        mobile: mobile,
                        id: data.id
                    });
                }
                $('#address-id').val(data.id);

                order.swipeNext();
            }
        });

    });

    /* Order Confirmation */
    $('.accordian-item-link').click(function (e) {
        e.preventDefault();
        $('.accordian-item').removeClass('active');
        $(this).parent().addClass('active');
    });

    /**
     * Lookup valid addresses for a post code
     */
    var verifyAddress = function () {

        if ($('#address-id').val() === 0 || $('#address-id').val() === '') {
            var initialPostCode = $('#filterPostcode').val().toUpperCase().replace(/[^A-Z0-9]/g, "");

            //Preselect existing address for logged-in users
            var existingAddresses = $('#order-address').find('option');
            if (existingAddresses.length > 2) {
                var foundSavedAddress = false;
                existingAddresses.filter(function () {
                    if ($(this).text().match(initialPostCode) && !foundSavedAddress) {
                        foundSavedAddress = true;
                        $('#address-id').val($(this).val());
                        $('#new_delivery_address').fadeOut();
                        $('#order-address').show();
                        $('#new-address').val(false);
                        $('#addr-st').val('');
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
        }
    };

});

var postCodeLookup = function (postcode) {

    $('#suggested-addresses').val(0);

    if ($('#suggested-addresses').find('option').length > 1) {
        return;
    }

    var $street = $('#addr-st');

    var apiUrl = 'https://api.ideal-postcodes.co.uk/v1/postcodes/' + postcode;

    $.getJSON(apiUrl,
        {
            api_key: 'ak_i1kkwsp8EIoMBD8vWt8q9NZSG74De'
        },
        function (data) {
            if (data.code === 2000) {
                console.log(data.result)

                $.each(data.result, function (key, value) {

                    var address = value.line_1;

                    if (value.line_2) {
                        address = address + ', ' + value.line_2;
                    }

                    if (value.line_3) {
                        address = address + ', ' + value.line_3;
                    }

                    $('#suggested-addresses')
                        .append($("<option></option>")
                            .attr("value", address)
                            .text(address));
                });

                $('#suggested-addresses').change(function () {
                    $("#suggested-addresses").find("option:selected").each(function () {
                        if (this.value !== '0') {
                            $street.val($(this).text());
                        } else {
                            $street.val('');
                        }
                    });
                });

            } else {
                console.log(data);
            }
        });
};

function createCartPage(wines, wineCount) {


    $('input[name="wines"]').val(JSON.stringify(wines));

    $('.no-bottles').hide();
    $('.order-bottle').remove();

    //Creates some html for each to be displayed on the review page

    wines.forEach(function (wine) {

        var $td = $('<td>')
            .attr('id', 'wine-' + wines.indexOf(wine))
            .addClass('order-table-bottle wine-bottle-' + wine.price.substr(1, 2))
            .append($('<a/>', { href: '#', text: 'x' }).addClass('delete'))
            .append('<div class="wine-bottle"></div>');

        for (var key in wine) {
            if (wine.hasOwnProperty(key)) {
                if (key != 'price') {
                    if (key == 'food' && wine['food'] && wine['food'].length > 0) {
                        var foods = wine[key];
                        var $ul = $('<ul/>').addClass('food');

                        foods.sort(function (a, b) {
                            return a.name.length - b.name.length;
                        });

                        foods.forEach(function (food) {
                            var foodName = food.name;

                            if (food.preparationName) {
                                foodName += ' (' + food.preparationName + ')'
                            }

                            $ul.append($('<li/>', {
                                text: foodName
                            }));

                        });
                        $ul.appendTo($td);
                    } else if (key == 'wineType') {
                        if (wine[key] && wine[key].name) {
                            $('<span/>', {
                                text: wine[key].name
                            }).addClass(key).appendTo($td);
                        }
                    } else {

                        if (wine[key] && key !== 'complete') {
                            $('<span/>', {
                                text: wine[key]
                            }).addClass(key).appendTo($td);
                        }
                    }
                }
            }
        }

        var $pricetd = $('<td>').addClass('order-table-bottle-price').append($('<span/>', { text: wine['price'] }).addClass('price'));

        $('.add-bottle').before($('<tr>').addClass('order-bottle').append($td).append($pricetd));

        //Reset prefs
        clearPreferences();

    });

    if (wineCount == 0) {
        $('.add-bottle').show();
    } else {
        $('.add-bottle').hide();
    }

    $('.btn-checkout').show();

    calculateTotalCost();
}

var clearPreferences = function () {
    $('.tab').removeClass('active');
    $('.prefs-overview, .food-limit, .occasion-limit').hide();
    $('.prefs-list li').removeClass('selected');
    $('.prefs-overview-list li').empty().append('<a href=""><span>+</span></a>').removeClass('empty').addClass('empty');
    $('input[name="specific-wine"]').val('');

    cleanupEvents();
};

var cleanupEvents = function () {
    for (var i = 0; i < events.length; i++) {
        if (events[i].type == 'matchingWine') {
            events.splice(i, 1);
        }
    }
};

var resetEventsForEmptyCart = function () {
    events = [];

    events.push({
        type: 'slideChange'
    });

    events.push({
        type: 'slideChange',
        name: '1'
    });

};

function calculateTotalCost() {
    var totalCost = 0;
    secondBottle = false;

    $('.order-bottle').each(function (i, el) {
        $price = $(el).find('.price');

        if (i > 0) {
            var discountedPrice = parseInt($price.text().substr(1, 2)) - 5;
            totalCost += discountedPrice;
            $price.wrap('<del></del>');
            $price.parent().after($('<span/>', { text: '£' + discountedPrice }).addClass('price'));
        } else {
            totalCost += parseInt($price.text().substr(1, 2));
        }

    });

    $('.total-cost span').text('£' + totalCost);

    var bottlesInTheCart = $('.order-bottle').length;
    $('.cart-count').show().text(bottlesInTheCart);
    if (bottlesInTheCart) {

    }
}


// Read a page's GET URL variables and return them as an associative array.
function getUrlVars() {
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for (var i = 0; i < hashes.length; i++) {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}