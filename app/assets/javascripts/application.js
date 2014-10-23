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
//= require vendor/custom-select-plugin

var ready = function() {
    // console.log('Doc is apparently ready');
    if (typeof(admin) !== 'undefined' && admin !== null && admin === true) {

    } else {

    }

};

$(function() {

	/* Header */

	$('.menu-link').click(function(e) {
		e.preventDefault();
		$('.menu-link').toggleClass('slide');
		$('.container').toggleClass('menu-visible');
		$('.aside-bar').toggleClass('visible');
	});

	$('.cart-link').click(function(e) {
		e.preventDefault();
		order.swipeTo(3, 500, false);
	});


	/* Walkthrough */

	var mySwiper = $('#walkthrough').swiper({
		mode: 'horizontal',
		speed: 200,
		pagination: '.pagination',
		paginationClickable: true
	});


	/* Order */

	var order = $('#order').swiper({
		mode: 'horizontal',
		speed: 200,
		noSwiping: true,
		simulateTouch: false,
		onlyExternal: true,
        onSlideChangeStart: function(swiper) {
            if (swiper.activeSlide().id == 'delivery-panel')
            {
                verifyAddress();
            }
        }
	});

	$('.next-slide').click(function(e) {
		e.preventDefault();
		order.swipeNext();
	});

	/* Create breadcrumbs */
	var $breadcrumbsContainer = $('<div/>').addClass('breadcrumbs-container');
	var $breadcrumbs = $('<ul/>').addClass('breadcrumbs');
	$breadcrumbsContainer.append($breadcrumbs);
	order.slides.forEach(function(slide) {
		var breadcrumb = slide.id.split('-')[0];
		$breadcrumbs.append($('<li/>').append($('<a/>', { text: breadcrumb })));
	});
	$('.main-header').after($breadcrumbsContainer);

	/* Availabilty */
	try {
		$('#filterPostcode').val(getUrlVars()["postcode"].replace('+', ' '));
	} catch(err) {
		console.log(err);
	}


	/* Bottle array */

	var wines = [];

	var wine = function() {
		this.id,
		this.quantity = 0,
		this.label = '',
		this.price = '',
		this.specificWine = '',
		this.food = [],
		this.occasion = [],
		this.category = ''
	}

	var food = function(id, name) {
		this.id = id,
		this.name = name
	}

	var wineCount = 0;


	/* Select a Bottle */

	$('.bottle-link').click(function(e) {
		if(!$('.close').hasClass('hover')) {
			$('.bottle-info').removeClass('active');
			$(this).parent().find('.bottle-info').addClass('active');
		}
	});

	$('.order-panel-overlay').css({
		'height': $(this).parent().height()+'px'
	});

	$('.close').hover(function() {
		$(this).addClass('hover');
	}, function() {
		$(this).removeClass('hover');
	});

	$('.close').click(function(e) {
		$('.bottle-info').removeClass('active');
	});

	$('.select-bottle').click(function(e) {
		e.preventDefault();
		$('.bottle-info').removeClass('active');

		wines[wineCount] = new wine();
		wines[wineCount].quantity = 1;
		wines[wineCount].label = $(this).parent().find('.label').text();
		wines[wineCount].price = $(this).parent().find('.price').text();
		wines[wineCount].category = $(this).parent().data('category-id');
		console.log(wines);

		order.swipeNext();
	});

	/* Preferences */

	var ingredientCount, cartCount = 0;

	$('.tab-list li a').click(function(e) {
		e.preventDefault();
		console.log('clicked');
		$('.prefs-overview').show();
		$($(this).attr('href')).parent().find('.tab').removeClass('active');
		$($(this).attr('href')).addClass('active');
	});

	$(document).on('click', '.prefs-list-bottom li a', function(e) {
		e.preventDefault();

		var $this = $(this);
		var id = $this.parent().attr('id');
		var name = $this.parent().find('span').text();

		if(!$this.parent().hasClass('selected')) {
			wines[wineCount].food.push( new food( id, name ) );

			$this.parent().addClass('selected');
			$this.closest('.tab').removeClass('active');
			$('.select-category').text('Add another ingredient?');

			$img = $this.find('img').clone();
			$img.attr('id', 'food-'+id);
			$empty = $('.prefs-overview-list .empty').first();
			$empty.find('span').replaceWith($img);
			$empty.removeClass('empty');

			if($('.prefs-overview-list .empty').length == 0) $('.food-limit').show();
		} else {
			$this.parent().removeClass('selected');
			$('#food-'+$this.parent().attr('id')).closest('li').addClass('empty')
			$('#food-'+$this.parent().attr('id')).replaceWith('<span>+</span>');
		}
	});

	$(document).on('click', '.prefs-overview-list li a', function(e) {
		e.preventDefault();
		$this = $(this);
		if($this.hasClass('empty')) {
			$('prefs-list-bottom').closest('.tab').removeClass('active');
		} else {
			$foodid = $this.find('img').attr('id').split('-');
			$('#'+$foodid[1]).removeClass('selected');
			$('.food-limit').hide();
			$this.parent().addClass('empty');
			$this.find('img').replaceWith('<span>+</span>');
		}
	});

	$('#select-preferences').click(function(e) {

		console.log(wines);

		if($('input[name="specific-wine"]').val() != '') {
			wines[wineCount].specificWine = $('input[name="specific-wine"]').val();
		}

		$('.order-table-bottle, .order-table-bottle-price').remove();

		//loop though wines
		wines.forEach(function(wine) {

			var $td = $('<td>').addClass('order-table-bottle').append($('<a/>', { text: 'x' }).addClass('close')).append('<div class="wine-bottle"></div>');

			for (var key in wine) {
				if (wine.hasOwnProperty(key)) {
					if(key != 'price') {
						if(key == 'food') {
							var foods = wine[key];
							var $ul = $('<ul/>').addClass('food');

							//sort foods
							foods.sort(function(a, b){
								return a.name.length - b.name.length;
							});

							foods.forEach(function(food) {
								$ul.append($('<li/>', {
									text: food.name
								}));
							});
							$ul.appendTo($td);
						} else {
							$('<span/>', {
								text: wine[key]
							}).addClass(key).appendTo($td);
						}
					}
				}
			}

			var $pricetd = $('<td>').addClass('order-table-bottle-price').append($('<span/>', { text: wine['price'] }).addClass('price'));

			$('.add-bottle').before($('<tr>').append($td).append($pricetd));

		});

		$('.cart-count').show().text(parseInt($('.cart-count').text()) + 1);

		$('.btn-checkout').show();

	});

	$(document).on('click', '.order-table .close', function(e) {
		$(this).closest('tr').remove();
	});

	$('.add-bottle-link').click(function(e) {
		e.preventDefault();

		order.swipeTo(1, 500, false);

		wineCount++;

		$(this).parent().hide();

	})


	$(document).on('click', '#account-link', function(e) {
		e.preventDefault();
		if($('#account-form').hasClass('register-form')) {
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

	$('#delivery-details').click(function(e) {

		e.preventDefault();

		if($('#account-form').hasClass('register-form')) {

			//Needs Validation
			var first_name = $('input[name="user[first_name]"]').val(),
				last_name = $('input[name="user[last_name]"]').val(),
				email = $('input[name="user[email]"]').val(),
				mobile = $('input[name="user[mobile]"]').val(),
				password = $('input[name="user[password]"]').val(),
				password_confirmation = $('input[name="user[password_confirmation]"]').val();

			var data = "user[first_name]="+first_name+"&user[last_name]="+last_name+"&user[email]="+email+"&user[mobile]="+mobile+"&user[password]="+password+"&user[password_confirmation]="+password_confirmation;

			console.log(data);

			$.ajax({
				type: "POST",
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))},
				url: '/signup/create',
				data: data,
				error: function(data) {
					//Response
					console.log(data);
					var errors = data.responseJSON.errors;
					if(errors) {
						var $errorList = $('#sing-in-errors');
						$errorList.empty().show();
						errors.forEach(function(error) {
							$errorList.append('<li>'+error+'</li>');
						});
					}
				},
				success: function(data) {
					order.swipeNext();
				}
		    });

		} else if($('#account-form').hasClass('signin-form')) {
			//Needs Validation
			var	email = $('input[name="user[email]"]').val();
				password = $('input[name="user[password]"]').val();

			var data = "&user[email]="+email+"&user[password]="+password;

			console.log(data);

            $.ajax({
                type: "POST",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))
                },
                url: '/users/sign_in.json',
                data: data,
                error: function (data) {
                    //TODO: Log this

                    var $errorList = $('#sing-in-errors');
                    $errorList.empty().show();
                    $errorList.append('<li>There was an error communicating with the server. Please try again.</li>');
                    console.log(data);
                },
                success: function (data) {
                    if(data.success) {
                        var initialPostCode = $('#filterPostcode').val().toUpperCase().replace(/[^A-Z0-9]/g, "");
                        var foundSavedAddress = false;
                        var $select = $('#order-address');
                        if(data.addresses && data.addresses.length > 0) {
                            var addresses = JSON.parse(data.addresses);
                            for (var i=0; i < addresses.length; i++){
                                var address = addresses[i];
                                var fullAddress = address.detail + ' ' + address.street + ' ' + address.postcode;

                                if(address.postcode.match(initialPostCode) && address.postcode.match(initialPostCode).length > 0 && !foundSavedAddress) {
                                    $select.append('<option value=' + address.id + ' selected="selected">' + fullAddress + '</option>');
                                    foundSavedAddress = true;
                                } else {
                                    $select.append('<option value=' + address.id + '>' + fullAddress + '</option>');
                                }
                            }
                            if(foundSavedAddress) {
                                $('#new_delivery_address').fadeOut();
                            }
                        }

                        order.swipeNext();
                    } else {
                        var errors = data.errors;
                        if(errors) {
                            var $errorList = $('#sing-in-errors');
                            $errorList.empty().show();
                            errors.forEach(function(error) {
                                $errorList.append('<li>'+error+'</li>');
                            });
                        }
                    }

                }
            });
		}

	});


	/* Address Details */

	$('#address-details').click(function(e) {

		e.preventDefault();

        if($('#address-id').val() !== '' && $('#address-id').val() !== '0') {
            order.swipeNext();
            return;
        }

        //Needs Validation
		var address_d = $('#addr-no').val(),
			address_s = $('#addr-st').val(),
			address_p = $('#addr-pc').val();

		var data = "address_d="+address_d+"&address_s="+address_s+"&address_p="+address_p;

		$.ajax({
		    type: "POST",
		    beforeSend: function(xhr) {
		        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))
		    },
		    url: '/signup/address',
		    data: data,
		    error: function(data) {
				//Response
				console.log(data);
                //TODO: Log error to Sentry.
                //TODO: Display user friendly error.
			},
			success: function(data) {
				console.log(data);
                $('#address-id').val(data.id);
				order.swipeNext();
			}
		});

	});

	/* Order Confirmation */
	$('.accordian-item-link').click(function(e) {
		e.preventDefault();
		$('.accordian-item').removeClass('active');
		$(this).parent().addClass('active');
	});

    /**
     * Lookup valid addresses for a post code
     */
    var verifyAddress = function() {
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
    };

});

var postCodeLookup = function(postcode) {


    if($('#suggested-addresses').find('option').length > 1)
    {
        return;
    }

    var $street = $('#addr-st');

    var apiUrl = 'https://api.ideal-postcodes.co.uk/v1/postcodes/' + postcode;

    $.getJSON(apiUrl,
        {
            api_key: 'ak_i1kkwsp8EIoMBD8vWt8q9NZSG74De'
        },
        function (data) {
            if(data.code === 2000) {
                console.log(data.result)

                $.each(data.result, function (key, value) {

                    var address = value.line_1;

                    if(value.line_2) {
                        address = address + ', ' + value.line_2;
                    }

                    if(value.line_3) {
                        address = address + ', ' + value.line_3;
                    }

                    $('#suggested-addresses')
                        .append($("<option></option>")
                            .attr("value", address)
                            .text(address));
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

            } else {
                console.log(data);
            }
        });
}


// Read a page's GET URL variables and return them as an associative array.
function getUrlVars() {
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++) {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}