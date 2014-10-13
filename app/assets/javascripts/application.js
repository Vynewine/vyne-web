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
//= require maskedinput
//= require forms
//# require vendor/retina.min
//= require vendor/swiper_min

var ready = function() {
    // console.log('Doc is apparently ready');
    if (typeof(admin) !== 'undefined' && admin !== null && admin === true) {
    } else {
        // console.log('Executing onReady functions');
        // Transferred from client.js
        // loadCrappyCode();
        // formStepSetup();
    }

};
// console.log(2);
$(function() {

	$('.menu-link').click(function(e) {
		e.preventDefault();
		$('.menu-link').toggleClass('slide');
		$('.container').toggleClass('menu-visible');
		$('.aside-bar').toggleClass('visible');
	});

	var mySwiper = $('#walkthrough').swiper({
		mode: 'horizontal',
		pagination: '.pagination',
		paginationClickable: true
	});

	var order = $('#order').swiper({
		mode: 'horizontal',
		noSwiping: true,
		simulateTouch: false,
		onlyExternal: true
	});

	$('.next-slide').click(function(e) {
		e.preventDefault();
		order.swipeNext();
	});

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

	$('.tab').hide();
	$('.tab-list li a').click(function(e) {
		e.preventDefault();
		$('.preferences .slideable').addClass('first-level');
		$('.tab-list li').removeClass('active');
		$(this).parent().addClass('active');

		$('.tab').hide();

		$($(this).attr('href')).show();
		$($(this).attr('href')).find('.prefs-list-container').addClass('visible');
	});

	$('.prefs-list li a').click(function(e) {
		e.preventDefault();
		$('.preferences .slideable').addClass('second-level');
		$(this).closest('.prefs-list-container').addClass('visible');
		$('.prefs-list li').removeClass('active');
		$(this).parent().addClass('active');
	});

	$('.slideable-back').click(function(e) {
		e.preventDefault();
		if($(this).hasClass('first')) {
			$('.preferences .slideable').removeClass('first-level');
		} else {
			$('.preferences .slideable').removeClass('second-level');
		}
	});

	$('.prefs-box').hide();
	$('.prefs-list-top li a').click(function(e) {
		e.preventDefault();
		$('.prefs-box').hide();
		$($(this).attr('href')).show();
	});

	$('.prefs-list-bottom li a').click(function(e) {
		e.preventDefault();

		var ingredientCount = parseInt($('.ingredient-count').text());

		if($(this).parent().hasClass('selected')) {
			
		} else {
			if(ingredientCount < 3) {
				$('.ingredient-count').text(parseInt($('.ingredient-count').text()) + 1);
				$('.select-category').text('Add another ingredient?');
				$('.preferences .slideable').removeClass('second-level');
				$(this).parent().addClass('selected');
				$('.prefs-overview').addClass('visible');
				$('.prefs-overview-list').prepend('<li><a href="">'+$(this).text()+'</a></li>');
			}
		}
	});

	$('.prefs-overview-popup-link').click(function(e) {
		e.preventDefault();
		$(this).parent().find('.prefs-overview-popup').toggle().toggleClass('open');
	})

	$(document).on('click', '.prefs-overview-list li a', function(e) {
		e.preventDefault();
		$(this).parent().remove();
	});

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
						var $errorList = $('.order-panel-content.register .errors');
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

		} else if($('#account-form').hasClass('signup-form')) {
			//Needs Validation
			var	email = $('input[name="user[email]"]').val()
				password = $('input[name="user[password]"]').val();

			var data = "&user[email]="+email+"&user[password]="+password;

			console.log(data);

			$.ajax({
				type: "POST",
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))},
				url: '/signup/create',
				data: data,
				error: function(data) {
					//Response
					console.log(data);
				},
				success: function(data) {
					order.swipeNext();
				}
		    });
		}

	});

	$('#address-details').click(function(e) {

		e.preventDefault();

		//Needs Validation
		var address_d = $('input[name="user[address_d]"]').val(),
			address_s = $('input[name="user[address_s]"]').val(),
			address_p = $('input[name="user[address_p]"]').val();

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
			},
			success: function(data) {
				console.log(data);
				order.swipeNext();
			}
		});

	});

});