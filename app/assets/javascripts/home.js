var textSwitchInterval;

"use strict";

var homeJsReady = function () {

    /**
     * Execute always
     */

    if (textSwitchInterval) {
        clearInterval(textSwitchInterval);
    }

    /**
     * Execute only when home page is loaded
     */

    if ($('body.home').length) {

        $('#postcode-check').submit(function (event) {
            event.preventDefault();
            var postcodeField = $('#filterPostcode');
            var postcode = postcodeField.val().toUpperCase().trim();
            var validation = validatePostcode(postcode);
            if (validation) {
                postcodeField.val(validation);
                this.submit();
            } else {
                $('#postcode-error').show();
            }
        });

        /**
         * =======================================
         * Function: Resize Background
         * =======================================
         */
        var resizeBackground = function () {

            $('.section-background-video > video').each(function (i, el) {
                var $el = $(el),
                    $section = $el.parent(),
                    min_w = 300,
                    video_w = 16,
                    video_h = 9,
                    section_w = $section.outerWidth(),
                    section_h = $section.outerHeight(),
                    scale_w = section_w / video_w,
                    scale_h = section_h / video_h,
                    scale = scale_w > scale_h ? scale_w : scale_h,
                    new_video_w, new_video_h, offet_top, offet_left;

                if (scale * video_w < min_w) {
                    scale = min_w / video_w;
                }

                new_video_w = scale * video_w;
                new_video_h = scale * video_h;
                offet_left = ( new_video_w - section_w ) / 2 * -1;
                offet_top = ( new_video_h - section_h ) / 2 * -1;

                $el.css('width', new_video_w);
                $el.css('height', new_video_h);
                $el.css('marginTop', offet_top);
                $el.css('marginLeft', offet_left);
            });

        };

        /* =======================================
         * Preloader
         * =======================================
         */
        if ($.fn.jpreLoader && $('body').hasClass('enable-preloader')) {
            var $body = $('body');

            $body.jpreLoader({
                showSplash: false
                // autoClose : false,
            }, function () {
                $body.addClass('done-preloader');
                $(window).trigger('resize');
            });
        }

        /* =======================================
         * Video Embed Async Load
         * =======================================
         */
        $(window).on('load', function () {
            $('.video-async').each(function (i, el) {
                var $el = $(el),
                    source = $el.data('source'),
                    video = $el.data('video'),
                    color = $el.data('color');

                if (source == 'vimeo') {
                    $el.attr('src', '//player.vimeo.com/video/' + video + ( color ? '?color=' + color : '' ));
                } else if (source == 'youtube') {
                    $el.attr('src', '//www.youtube.com/embed/' + video + '?rel=0');
                }
            });
        });

        /**
         * =======================================
         * Resize Video Background
         * =======================================
         */
        $(window).on('resize', function () {
            resizeBackground();
        });
        resizeBackground();
        /**
         * =======================================
         * Initiate Stellar JS
         * =======================================
         */
        if ($.fn.stellar && !isMobile.any()) {
            $.stellar({
                responsive: true,
                horizontalScrolling: false,
                hideDistantElements: false,
                verticalOffset: 0,
                horizontalOffset: 0
            });
        }

        /**
         * =======================================
         * Numbers (Counter Up)
         * =======================================
         */
        if ($.fn.counterUp) {
            $('.counter-up').counterUp({
                time: 1000
            });
        }

        /**
         * =======================================
         * Scroll Spy
         * =======================================
         */
        var toggleHeaderFloating = function () {
            // Floating Header
            if ($(window).scrollTop() > 80) {
                $('.header-section').addClass('floating');
            } else {
                $('.header-section').removeClass('floating');
            }
        };

        $(window).on('scroll', toggleHeaderFloating);
        toggleHeaderFloating();

        /**
         * =======================================
         * One Page Navigation
         * =======================================
         */
        if ($.fn.onePageNav) {
            $('#header-nav').onePageNav({
                scrollSpeed: 1000,
                filter: ':not(.external)',
                begin: function () {
                    if ($(window).width() <= 991) {
                        $('#navigation').collapse('toggle');
                    }
                },
                scrollChange: function ($currentListItem) {
                    if ($currentListItem.find('a').attr('href') === '#discover') {
                        //This can be used to enable something when user scrolls to this section
                    }
                }
            });
        }

        /**
         * =======================================
         * Animations
         * =======================================
         */
        if ($('body').hasClass('enable-animations') && !isMobile.any()) {
            var $elements = $('*[data-animation]');

            $elements.each(function (i, el) {

                var $el = $(el),
                    animationClass = $el.data('animation');

                $el.addClass(animationClass);
                $el.addClass('animated');
                $el.addClass('wait-animation');

                $el.one('inview', function () {
                    $el.removeClass('wait-animation');
                    $el.addClass('done-animation');
                });
            });
        }

        /**
         * =======================================
         * Anchor Link
         * =======================================
         */
        $('body').on('click', 'a.anchor-link', function (e) {
            e.preventDefault();

            var $a = $(this),
                $target = $($a.attr('href'));

            if ($target.length < 1) return;

            $('html, body').animate({scrollTop: $target.offset().top}, 1000);
        });

        /**
         * =======================================
         * Form AJAX
         * =======================================
         */
        $('form').each(function (i, el) {

            var $el = $(this);

            if ($el.hasClass('form-ajax-submit')) {

                $el.on('submit', function (e) {
                    e.preventDefault();

                    var $alert = $el.find('.form-validation'),
                        $submit = $el.find('button'),
                        action = $el.attr('action');

                    // button loading
                    $submit.button('loading');

                    // reset alert
                    $alert.removeClass('alert-danger alert-success');
                    $alert.html('');

                    $.ajax({
                        type: 'POST',
                        url: action,
                        data: $el.serialize() + '&ajax=1',
                        dataType: 'JSON',
                        success: function (response) {

                            // custom callback
                            $el.trigger('form-ajax-response', response);

                            // error
                            if (response.status == 'error') {
                                $alert.html(response.message);
                                $alert.addClass('alert-danger').fadeIn(500);
                            }
                            // success
                            else if (response.status == 'error') {
                                $el.trigger('reset');
                                $alert.addClass('alert-success').fadeIn(500);
                                $alert.html(response.message);
                            }
                            else {
                                $alert.addClass('alert-' + response.status).fadeIn(500);
                            }

                            // reset button
                            $submit.button('reset');
                        }
                    })
                });
            }
        });

        /**
         * =======================================
         * Flipping words effect
         * =======================================
         */

        var switchText = function () {
            var id = 0;
            var total = $('span[class^="switch-text-"]').length - 1;
            textSwitchInterval = setInterval(function () {

                var $currentText = $('.switch-text-' + id);
                var $nextTextToShow = $('.switch-text-' + (id + 1));

                if (id >= total) {
                    $currentText = $('.switch-text-' + total);
                    $nextTextToShow = $('.switch-text-0');
                    id = -1;
                }

                var $switchTextContainer = $('.switch-text');
                $switchTextContainer.css({"width": $currentText.width() + 'px'});
                var width = $nextTextToShow.width();

                $currentText.fadeOut(function () {
                    $('.switch-text').animate({
                        width: width + 'px'
                    }, 500, function () {
                        $nextTextToShow.fadeIn(400).css('visibility', 'visible');
                        id++;
                    });
                });
            }, 2000);
        };

        switchText();
    }
};

$(document).on('page:load', homeJsReady);
$(document).ready(homeJsReady);
