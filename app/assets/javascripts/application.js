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
//= require vendor/retina.min
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
		$('.preferences').addClass('first-level');
		$('.tab-list li').removeClass('active');
		$(this).parent().addClass('active');

		$('.tab').hide();

		$($(this).attr('href')).show();
		$($(this).attr('href')).find('.prefs-list-container').addClass('visible');
	});

	$('.prefs-list li a').click(function(e) {
		e.preventDefault();
		$('.preferences').addClass('second-level');
		$(this).closest('.prefs-list-container').addClass('visible');
		$('.prefs-list li').removeClass('active');
		$(this).parent().addClass('active');
	});

	$('.prefs-box').hide();
	$('.prefs-list-top li a').click(function(e) {
		e.preventDefault();
		$('.prefs-box').hide();
		$($(this).attr('href')).show();
	});

	$('.prefs-list-bottom li a').click(function(e) {
		e.preventDefault();
		if($(this).parent().hasClass('selected')) {
			
		} else {
			$(this).parent().addClass('selected');
			$('.prefs-overview').addClass('visible');
			$('.prefs-overview-list').prepend('<li><a href="">'+$(this).text()+'</a></li>');
		}
	});

	$(document).on('click', '.prefs-overview-list li a', function(e) {
		e.preventDefault();
		$(this).parent().remove();
	});

});