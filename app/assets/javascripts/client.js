// page init
jQuery(function(){
    jcf.customForms.replaceAll();
    initCycleCarousel();
    initBackgroundResize();
    initPushMenu();
    initChosenTimeText();
});

// cycle scroll gallery init
function initCycleCarousel() {
    jQuery('.cycle-gallery').scrollAbsoluteGallery({
        mask: '.mask',
        slider: '.slideset',
        slides: '.slide',
        btnPrev: 'a.btn-prev',
        btnNext: 'a.btn-next',
        generatePagination: '.pagination',
        stretchSlideToMask: true,
        maskAutoSize: true,
        autoRotation: false,
        switchTime: 3000,
        animSpeed: 500
    });
}

// stretch background to fill blocks
function initBackgroundResize() {
    jQuery('.bg-page').each(function() {
        ImageStretcher.add({
            container: this,
            image: 'img'
        });
    });
}

function initPushMenu(){
    jQuery('#wrapper').pushMenu({
        opener: '.opener',
        slide: '.aside-bar',
        activeClass: 'pushed',
        direction: 'right',
        hideOnClickOutside: false,
        pushContainer: false,
        stretchSlideToContainer: false,
        animSpeed: 400,
        onInit: function(self){
            self.header = jQuery('#header');
        },
        animStart: function(state){
            var self = this;
            if(state){
                self.header.stop().animate({
                    marginLeft:self.slideWidth * -1
                }, self.options.animSpeed);
            } else {
                self.header.stop().animate({
                    marginLeft: 0
                }, self.options.animSpeed);
            }
        }
    });
}

function initChosenTimeText(){
    var form = jQuery('.schedule-form');
    var radios = form.find('input[type="radio"]');
    var chosenTimeText = form.find('.chosen-time');
    radios.each(function(){
        var radio = jQuery(this);
        var label = jQuery('label').filter('[for = '+ radio.attr('id') +']');
        var labelText = label.html();
        if(radio.prop('checked')){
            chosenTimeText.html(labelText)
        }
        radio.on('change', function(){
            chosenTimeText.html(labelText)
        })
    });
}

/*
 * jQuery PushMenu plugin
 */
;(function($){
    function PushMenu(options){
        this.options = $.extend({
            holder: null,
            opener: '.opener',
            slide: '.slide',
            activeClass: 'pushed',
            direction: 'left', // or right
            hideOnClickOutside: false,
            pushContainer: true,
            stretchSlideToContainer: false,
            animSpeed: 400
        }, options);
        
        this.init();
    }
    PushMenu.prototype = {
        init: function(){
            this.findElements();
            this.makeCallback('onInit', this);
            this.attachEvents();
        },
        findElements: function(){
            this.holder = $(this.options.holder);
            this.opener = this.holder.find(this.options.opener);
            this.slide = this.holder.find(this.options.slide);

            this.slideWidth = this.slide.outerWidth();
            this.propObj = {};
            
            if (this.options.pushContainer){
                this.box = this.holder;
                this.direction = (this.options.direction === 'right') ? -1 : 1;
                this.propObj.marginLeft = (this.holder.hasClass(this.options.activeClass)) ? this.slideWidth * this.direction : 0
            } else {
                this.box = this.slide;
                this.propObj = {position: 'absolute'};
                this.propObj[this.options.direction] = (this.holder.hasClass(this.options.activeClass)) ? this.slideWidth : 0;
            }

            this.box.css(this.propObj);

            if (this.holder.hasClass(this.options.activeClass)){
                if (this.options.stretchSlideToContainer){
                    this.slide.height(this.holder.outerHeight());
                }
            }
        },
        attachEvents: function(){
            var self = this;

            this.clickHandler = function(e){
                e.preventDefault();

                if (self.holder.hasClass(self.options.activeClass)) {
                    self.hideSlide();
                } else {
                    self.showSlide();
                }
            }
            this.outsideClickHandler = function(e) {
                if(self.options.hideOnClickOutside) {
                    var target = $(e.target);
                    if (!target.closest(self.slide).length && !target.closest(self.opener).length) {
                        self.hideSlide();
                    }
                }
            }
            this.resizeHandler = function(){
                //self.hideSlide();
            }

            if (this.holder.hasClass(this.options.activeClass)) {
                $(document).on('click touchstart', this.outsideClickHandler);
            }

            this.opener.on('click touchstart', this.clickHandler);
            $(window).on('resize orientationchange', this.resizeHandler);

        },
        showSlide: function(){
            var self = this;
            if (this.options.pushContainer){
                this.propObj.marginLeft = this.slideWidth * this.direction;
            } else {
                this.propObj[this.options.direction] = this.slideWidth;
            }

            this.makeCallback('animStart', true);
            this.box.stop().animate(this.propObj, this.options.animSpeed, function(){
                self.makeCallback('animEnd', true);
            });

            if (this.options.stretchSlideToContainer){
                this.slide.height(this.holder.outerHeight());
            }

            this.holder.addClass(this.options.activeClass);

            $(document).on('click touchstart', this.outsideClickHandler);
        },
        hideSlide: function(){
            var self = this;
            if (this.options.pushContainer){
                this.propObj.marginLeft = 0;
            } else {
                this.propObj[this.options.direction] = 0;
            }

            this.makeCallback('animStart', false);
            this.box.stop().animate(this.propObj, this.options.animSpeed, function(){
                self.makeCallback('animEnd', false);
            });

            this.holder.removeClass(this.options.activeClass)

            $(document).off('click touchstart', this.outsideClickHandler);
        },
        makeCallback: function(name) {
            if(typeof this.options[name] === 'function') {
                var args = Array.prototype.slice.call(arguments);
                args.shift();
                this.options[name].apply(this, args);
            }
        },
        destroy: function(){
            this.holder.css({marginLeft: ''}).removeClass(this.options.activeClass);
            this.opener.off('click touchstart', this.clickHandler);
            this.slide.css({position:'',left:'', right:'',height:''});
            $(window).off('resize orientationchange', this.resizeHandler);
            $(document).off('click touchstart', this.outsideClickHandler);
        }
    }

    $.fn.pushMenu = function(options){
        return this.each(function(){
            $(this).data('PushMenu', new PushMenu($.extend(options, {holder:this})));
        });
    };
})(jQuery)

/*
 * jQuery Cycle Carousel plugin
 */
;(function($){
    function ScrollAbsoluteGallery(options) {
        this.options = $.extend({
            activeClass: 'active',
            mask: 'div.slides-mask',
            slider: '>ul',
            slides: '>li',
            btnPrev: '.btn-prev',
            btnNext: '.btn-next',
            pagerLinks: 'ul.pager > li',
            generatePagination: false,
            pagerList: '<ul>',
            pagerListItem: '<li><a href="#"></a></li>',
            pagerListItemText: 'a',
            galleryReadyClass: 'gallery-js-ready',
            currentNumber: 'span.current-num',
            totalNumber: 'span.total-num',
            maskAutoSize: false,
            autoRotation: false,
            pauseOnHover: false,
            stretchSlideToMask: false,
            switchTime: 3000,
            animSpeed: 500,
            handleTouch: true,
            swipeThreshold: 15,
            vertical: false
        }, options);
        this.init();
    }
    ScrollAbsoluteGallery.prototype = {
        init: function() {
            if(this.options.holder) {
                this.findElements();
                this.attachEvents();
                this.makeCallback('onInit', this);
            }
        },
        findElements: function() {
            // find structure elements
            this.holder = $(this.options.holder).addClass(this.options.galleryReadyClass);
            this.mask = this.holder.find(this.options.mask);
            this.slider = this.mask.find(this.options.slider);
            this.slides = this.slider.find(this.options.slides);
            this.btnPrev = this.holder.find(this.options.btnPrev);
            this.btnNext = this.holder.find(this.options.btnNext);

            // slide count display
            this.currentNumber = this.holder.find(this.options.currentNumber);
            this.totalNumber = this.holder.find(this.options.totalNumber);

            // create gallery pagination
            if(typeof this.options.generatePagination === 'string') {
                this.pagerLinks = this.buildPagination();
            } else {
                this.pagerLinks = this.holder.find(this.options.pagerLinks);
            }

            // define index variables
            this.sizeProperty = this.options.vertical ? 'height' : 'width';
            this.positionProperty = this.options.vertical ? 'top' : 'left';
            this.animProperty = this.options.vertical ? 'marginTop' : 'marginLeft';

            this.slideSize = this.slides[this.sizeProperty]();
            this.currentIndex = 0;
            this.prevIndex = 0;

            // reposition elements
            this.options.maskAutoSize = this.options.vertical ? false : this.options.maskAutoSize;
            if(this.options.vertical) {
                this.mask.css({
                    height: this.slides.innerHeight()
                });
            }
            if(this.options.maskAutoSize){
                this.mask.css({
                    height: this.slider.height()
                });
            }
            this.slider.css({
                position: 'relative',
                height: this.options.vertical ? this.slideSize * this.slides.length : '100%'
            });
            this.slides.css({
                position: 'absolute'
            }).css(this.positionProperty, -9999).eq(this.currentIndex).css(this.positionProperty, 0);
            this.refreshState();
        },
        buildPagination: function() {
            var pagerLinks = $();
            if(!this.pagerHolder) {
                this.pagerHolder = this.holder.find(this.options.generatePagination);
            }
            if(this.pagerHolder.length) {
                this.pagerHolder.empty();
                this.pagerList = $(this.options.pagerList).appendTo(this.pagerHolder);
                for(var i = 0; i < this.slides.length; i++) {
                    $(this.options.pagerListItem).appendTo(this.pagerList).find(this.options.pagerListItemText).text(i+1);
                }
                pagerLinks = this.pagerList.children();
            }
            return pagerLinks;
        },
        attachEvents: function() {
            // attach handlers
            var self = this;
            if(this.btnPrev.length) {
                this.btnPrevHandler = function(e) {
                    e.preventDefault();
                    self.prevSlide();
                };
                this.btnPrev.click(this.btnPrevHandler);
            }
            if(this.btnNext.length) {
                this.btnNextHandler = function(e) {
                    e.preventDefault();
                    self.nextSlide();
                };
                this.btnNext.click(this.btnNextHandler);
            }
            if(this.pagerLinks.length) {
                this.pagerLinksHandler = function(e) {
                    e.preventDefault();
                    self.numSlide(self.pagerLinks.index(e.currentTarget));
                };
                this.pagerLinks.click(this.pagerLinksHandler);
            }

            // handle autorotation pause on hover
            if(this.options.pauseOnHover) {
                this.hoverHandler = function() {
                    clearTimeout(self.timer);
                };
                this.leaveHandler = function() {
                    self.autoRotate();
                };
                this.holder.bind({mouseenter: this.hoverHandler, mouseleave: this.leaveHandler});
            }

            // handle holder and slides dimensions
            this.resizeHandler = function() {
                if(!self.animating) {
                    if(self.options.stretchSlideToMask) {
                        self.resizeSlides();
                    }
                    self.resizeHolder();
                    self.setSlidesPosition(self.currentIndex);
                }
            };
            $(window).bind('load resize orientationchange', this.resizeHandler);
            if(self.options.stretchSlideToMask) {
                self.resizeSlides();
            }

            // handle swipe on mobile devices
            if(this.options.handleTouch && window.Hammer && this.mask.length && this.slides.length > 1 && isTouchDevice) {
                this.swipeHandler = Hammer(this.mask[0], {
                    dragBlockHorizontal: !this.options.vertical,
                    dragBlockVertical: this.options.vertical,
                    dragMinDistance: 1,
                    behavior: {
                        touchAction: this.options.vertical ? 'pan-x' : 'pan-y'
                    }
                }).on('touch release ' + (self.options.vertical ? 'dragup dragdown' : 'dragleft dragright'), function(e) {
                    switch(e.type) {
                        case 'touch':
                            if(self.animating) {
                                e.gesture.stopDetect();
                            } else {
                                clearTimeout(self.timer);
                            }
                            break;
                        case 'dragup':
                        case 'dragdown':
                        case 'dragleft':
                        case 'dragright':
                            e.gesture.preventDefault();
                            self.swipeOffset = -self.slideSize + e.gesture[self.options.vertical ? 'deltaY' : 'deltaX'];
                            self.slider.css(self.animProperty, self.swipeOffset);
                            clearTimeout(self.timer);
                            break;
                        case 'release':
                            if(Math.abs(e.gesture[self.options.vertical ? 'deltaY' : 'deltaX']) > self.options.swipeThreshold) {
                                if(e.gesture.direction == 'left' || e.gesture.direction == 'up') {
                                    self.nextSlide();
                                } else {
                                    self.prevSlide();
                                }
                            }
                            else {
                                var tmpObj = {};
                                tmpObj[self.animProperty] = -self.slideSize;
                                self.slider.animate(tmpObj, {duration: self.options.animSpeed});
                                self.autoRotate();
                            }
                            self.swipeOffset = 0;
                    }
                });
            }

            // start autorotation
            this.autoRotate();
            this.resizeHolder();
            this.setSlidesPosition(this.currentIndex);
        },
        resizeSlides: function() {
            this.slideSize = this.mask[this.options.vertical ? 'height' : 'width']();
            this.slides.css(this.sizeProperty, this.slideSize);
        },
        resizeHolder: function() {
            if(this.options.maskAutoSize) {
                this.mask.css({
                    height: this.slides.eq(this.currentIndex).outerHeight(true)
                });
            }
        },
        prevSlide: function() {
            if(!this.animating && this.slides.length > 1) {
                this.direction = -1;
                this.prevIndex = this.currentIndex;
                if(this.currentIndex > 0) this.currentIndex--;
                else this.currentIndex = this.slides.length - 1;
                this.switchSlide();
            }
        },
        nextSlide: function(fromAutoRotation) {
            if(!this.animating && this.slides.length > 1) {
                this.direction = 1;
                this.prevIndex = this.currentIndex;
                if(this.currentIndex < this.slides.length - 1) this.currentIndex++;
                else this.currentIndex = 0;
                this.switchSlide();
            }
        },
        numSlide: function(c) {
            if(!this.animating && this.currentIndex !== c && this.slides.length > 1) {
                this.direction = c > this.currentIndex ? 1 : -1;
                this.prevIndex = this.currentIndex;
                this.currentIndex = c;
                this.switchSlide();
            }
        },
        preparePosition: function() {
            // prepare slides position before animation
            this.setSlidesPosition(this.prevIndex, this.direction < 0 ? this.currentIndex : null, this.direction > 0 ? this.currentIndex : null, this.direction);
        },
        setSlidesPosition: function(index, slideLeft, slideRight, direction) {
            // reposition holder and nearest slides
            if(this.slides.length > 1) {
                var prevIndex = (typeof slideLeft === 'number' ? slideLeft : index > 0 ? index - 1 : this.slides.length - 1);
                var nextIndex = (typeof slideRight === 'number' ? slideRight : index < this.slides.length - 1 ? index + 1 : 0);

                this.slider.css(this.animProperty, this.swipeOffset ? this.swipeOffset : -this.slideSize);
                this.slides.css(this.positionProperty, -9999).eq(index).css(this.positionProperty, this.slideSize);
                if(prevIndex === nextIndex && typeof direction === 'number') {
                    var calcOffset = direction > 0 ? this.slideSize*2 : 0;
                    this.slides.eq(nextIndex).css(this.positionProperty, calcOffset);
                } else {
                    this.slides.eq(prevIndex).css(this.positionProperty, 0);
                    this.slides.eq(nextIndex).css(this.positionProperty, this.slideSize*2);
                }
            }
        },
        switchSlide: function() {
            // prepare positions and calculate offset
            var self = this;
            var oldSlide = this.slides.eq(this.prevIndex);
            var newSlide = this.slides.eq(this.currentIndex);
            this.animating = true;

            // resize mask to fit slide
            if(this.options.maskAutoSize) {
                this.mask.animate({
                    height: newSlide.outerHeight(true)
                }, {
                    duration: this.options.animSpeed
                });
            }

            // start animation
            var animProps = {};
            animProps[this.animProperty] = this.direction > 0 ? -this.slideSize*2 : 0;
            this.preparePosition();
            this.slider.animate(animProps,{duration:this.options.animSpeed, complete:function() {
                self.setSlidesPosition(self.currentIndex);

                // start autorotation
                self.animating = false;
                self.autoRotate();

                // onchange callback
                self.makeCallback('onChange', self);
            }});

            // refresh classes
            this.refreshState();

            // onchange callback
            this.makeCallback('onBeforeChange', this);
        },
        refreshState: function(initial) {
            // slide change function
            this.slides.removeClass(this.options.activeClass).eq(this.currentIndex).addClass(this.options.activeClass);
            this.pagerLinks.removeClass(this.options.activeClass).eq(this.currentIndex).addClass(this.options.activeClass);

            // display current slide number
            this.currentNumber.html(this.currentIndex + 1);
            this.totalNumber.html(this.slides.length);

            // add class if not enough slides
            this.holder.toggleClass('not-enough-slides', this.slides.length === 1);
        },
        autoRotate: function() {
            var self = this;
            clearTimeout(this.timer);
            if(this.options.autoRotation) {
                this.timer = setTimeout(function() {
                    self.nextSlide();
                }, this.options.switchTime);
            }
        },
        makeCallback: function(name) {
            if(typeof this.options[name] === 'function') {
                var args = Array.prototype.slice.call(arguments);
                args.shift();
                this.options[name].apply(this, args);
            }
        },
        destroy: function() {
            // destroy handler
            this.btnPrev.unbind('click', this.btnPrevHandler);
            this.btnNext.unbind('click', this.btnNextHandler);
            this.pagerLinks.unbind('click', this.pagerLinksHandler);
            this.holder.unbind({mouseenter: this.hoverHandler, mouseleave: this.leaveHandler});
            $(window).unbind('load resize orientationchange', this.resizeHandler);
            clearTimeout(this.timer);

            // destroy swipe handler
            if(this.swipeHandler) {
                this.swipeHandler.dispose();
            }

            // remove inline styles, classes and pagination
            this.holder.removeClass(this.options.galleryReadyClass);
            this.slider.add(this.slides).removeAttr('style');
            if(typeof this.options.generatePagination === 'string') {
                this.pagerHolder.empty();
            }
        }
    };

    // detect device type
    var isTouchDevice = /MSIE 10.*Touch/.test(navigator.userAgent) || ('ontouchstart' in window) || window.DocumentTouch && document instanceof DocumentTouch;

    // jquery plugin
    $.fn.scrollAbsoluteGallery = function(opt){
        return this.each(function(){
            $(this).data('ScrollAbsoluteGallery', new ScrollAbsoluteGallery($.extend(opt,{holder:this})));
        });
    };
}(jQuery));

/*
 * JavaScript Custom Forms Module
 */
jcf = {
    // global options
    modules: {},
    plugins: {},
    baseOptions: {
        unselectableClass:'jcf-unselectable',
        labelActiveClass:'jcf-label-active',
        labelDisabledClass:'jcf-label-disabled',
        classPrefix: 'jcf-class-',
        hiddenClass:'jcf-hidden',
        focusClass:'jcf-focus',
        wrapperTag: 'div'
    },
    // replacer function
    customForms: {
        setOptions: function(obj) {
            for(var p in obj) {
                if(obj.hasOwnProperty(p) && typeof obj[p] === 'object') {
                    jcf.lib.extend(jcf.modules[p].prototype.defaultOptions, obj[p]);
                }
            }
        },
        replaceAll: function(context) {
            for(var k in jcf.modules) {
                var els = jcf.lib.queryBySelector(jcf.modules[k].prototype.selector, context);
                for(var i = 0; i<els.length; i++) {
                    if(els[i].jcf) {
                        // refresh form element state
                        els[i].jcf.refreshState();
                    } else {
                        // replace form element
                        if(!jcf.lib.hasClass(els[i], 'default') && jcf.modules[k].prototype.checkElement(els[i])) {
                            new jcf.modules[k]({
                                replaces:els[i]
                            });
                        }
                    }
                }
            }
        },
        refreshAll: function(context) {
            for(var k in jcf.modules) {
                var els = jcf.lib.queryBySelector(jcf.modules[k].prototype.selector, context);
                for(var i = 0; i<els.length; i++) {
                    if(els[i].jcf) {
                        // refresh form element state
                        els[i].jcf.refreshState();
                    }
                }
            }
        },
        refreshElement: function(obj) {
            if(obj && obj.jcf) {
                obj.jcf.refreshState();
            }
        },
        destroyAll: function() {
            for(var k in jcf.modules) {
                var els = jcf.lib.queryBySelector(jcf.modules[k].prototype.selector);
                for(var i = 0; i<els.length; i++) {
                    if(els[i].jcf) {
                        els[i].jcf.destroy();
                    }
                }
            }
        }
    },
    // detect device type
    isTouchDevice: ('ontouchstart' in window) || window.DocumentTouch && document instanceof DocumentTouch,
    isWinPhoneDevice: navigator.msPointerEnabled && /MSIE 10.*Touch/.test(navigator.userAgent),
    // define base module
    setBaseModule: function(obj) {
        jcf.customControl = function(opt){
            this.options = jcf.lib.extend({}, jcf.baseOptions, this.defaultOptions, opt);
            this.init();
        };
        for(var p in obj) {
            jcf.customControl.prototype[p] = obj[p];
        }
    },
    // add module to jcf.modules
    addModule: function(obj) {
        if(obj.name){
            // create new module proto class
            jcf.modules[obj.name] = function(){
                jcf.modules[obj.name].superclass.constructor.apply(this, arguments);
            }
            jcf.lib.inherit(jcf.modules[obj.name], jcf.customControl);
            for(var p in obj) {
                jcf.modules[obj.name].prototype[p] = obj[p]
            }
            // on create module
            jcf.modules[obj.name].prototype.onCreateModule();
            // make callback for exciting modules
            for(var mod in jcf.modules) {
                if(jcf.modules[mod] != jcf.modules[obj.name]) {
                    jcf.modules[mod].prototype.onModuleAdded(jcf.modules[obj.name]);
                }
            }
        }
    },
    // add plugin to jcf.plugins
    addPlugin: function(obj) {
        if(obj && obj.name) {
            jcf.plugins[obj.name] = function() {
                this.init.apply(this, arguments);
            }
            for(var p in obj) {
                jcf.plugins[obj.name].prototype[p] = obj[p];
            }
        }
    },
    // miscellaneous init
    init: function(){
        if(navigator.pointerEnabled || navigator.msPointerEnabled) {
            // use pointer events instead of mouse events
            this.eventPress = navigator.pointerEnabled ? 'pointerdown' : 'MSPointerDown';
            this.eventMove = navigator.pointerEnabled ? 'pointermove' : 'MSPointerMove';
            this.eventRelease = navigator.pointerEnabled ? 'pointerup' : 'MSPointerUp';
        } else {
            // handle default desktop mouse events
            this.eventPress = 'mousedown';
            this.eventMove = 'mousemove';
            this.eventRelease = 'mouseup';
        }
        if(this.isTouchDevice) {
            // handle touch events also
            this.eventPress += ' touchstart';
            this.eventMove += ' touchmove';
            this.eventRelease += ' touchend';
        }

        setTimeout(function(){
            jcf.lib.domReady(function(){
                jcf.initStyles();
            });
        },1);
        return this;
    },
    initStyles: function() {
        // create <style> element and rules
        var head = document.getElementsByTagName('head')[0],
            style = document.createElement('style'),
            rules = document.createTextNode('.'+jcf.baseOptions.unselectableClass+'{'+
                '-moz-user-select:none;'+
                '-webkit-tap-highlight-color:rgba(255,255,255,0);'+
                '-webkit-user-select:none;'+
                'user-select:none;'+
            '}');

        // append style element
        style.type = 'text/css';
        if(style.styleSheet) {
            style.styleSheet.cssText = rules.nodeValue;
        } else {
            style.appendChild(rules);
        }
        head.appendChild(style);
    }
}.init();

/*
 * Custom Form Control prototype
 */
jcf.setBaseModule({
    init: function(){
        if(this.options.replaces) {
            this.realElement = this.options.replaces;
            this.realElement.jcf = this;
            this.replaceObject();
        }
    },
    defaultOptions: {
        // default module options (will be merged with base options)
    },
    checkElement: function(el){
        return true; // additional check for correct form element
    },
    replaceObject: function(){
        this.createWrapper();
        this.attachEvents();
        this.fixStyles();
        this.setupWrapper();
    },
    createWrapper: function(){
        this.fakeElement = jcf.lib.createElement(this.options.wrapperTag);
        this.labelFor = jcf.lib.getLabelFor(this.realElement);
        jcf.lib.disableTextSelection(this.fakeElement);
        jcf.lib.addClass(this.fakeElement, jcf.lib.getAllClasses(this.realElement.className, this.options.classPrefix));
        jcf.lib.addClass(this.realElement, jcf.baseOptions.hiddenClass);
    },
    attachEvents: function(){
        jcf.lib.event.add(this.realElement, 'focus', this.onFocusHandler, this);
        jcf.lib.event.add(this.realElement, 'blur', this.onBlurHandler, this);
        jcf.lib.event.add(this.fakeElement, 'click', this.onFakeClick, this);
        jcf.lib.event.add(this.fakeElement, jcf.eventPress, this.onFakePressed, this);
        jcf.lib.event.add(this.fakeElement, jcf.eventRelease, this.onFakeReleased, this);

        if(this.labelFor) {
            this.labelFor.jcf = this;
            jcf.lib.event.add(this.labelFor, 'click', this.onFakeClick, this);
            jcf.lib.event.add(this.labelFor, jcf.eventPress, this.onFakePressed, this);
            jcf.lib.event.add(this.labelFor, jcf.eventRelease, this.onFakeReleased, this);
        }
    },
    fixStyles: function() {
        // hide mobile webkit tap effect
        if(jcf.isTouchDevice) {
            var tapStyle = 'rgba(255,255,255,0)';
            this.realElement.style.webkitTapHighlightColor = tapStyle;
            this.fakeElement.style.webkitTapHighlightColor = tapStyle;
            if(this.labelFor) {
                this.labelFor.style.webkitTapHighlightColor = tapStyle;
            }
        }
    },
    setupWrapper: function(){
        // implement in subclass
    },
    refreshState: function(){
        // implement in subclass
    },
    destroy: function() {
        if(this.fakeElement && this.fakeElement.parentNode) {
            this.fakeElement.parentNode.insertBefore(this.realElement, this.fakeElement);
            this.fakeElement.parentNode.removeChild(this.fakeElement);
        }
        jcf.lib.removeClass(this.realElement, jcf.baseOptions.hiddenClass);
        this.realElement.jcf = null;
    },
    onFocus: function(){
        // emulated focus event
        jcf.lib.addClass(this.fakeElement,this.options.focusClass);
    },
    onBlur: function(cb){
        // emulated blur event
        jcf.lib.removeClass(this.fakeElement,this.options.focusClass);
    },
    onFocusHandler: function() {
        // handle focus loses
        if(this.focused) return;
        this.focused = true;

        // handle touch devices also
        if(jcf.isTouchDevice) {
            if(jcf.focusedInstance && jcf.focusedInstance.realElement != this.realElement) {
                jcf.focusedInstance.onBlur();
                jcf.focusedInstance.realElement.blur();
            }
            jcf.focusedInstance = this;
        }
        this.onFocus.apply(this, arguments);
    },
    onBlurHandler: function() {
        // handle focus loses
        if(!this.pressedFlag) {
            this.focused = false;
            this.onBlur.apply(this, arguments);
        }
    },
    onFakeClick: function(){
        if(jcf.isTouchDevice) {
            this.onFocus();
        } else if(!this.realElement.disabled) {
            this.realElement.focus();
        }
    },
    onFakePressed: function(e){
        this.pressedFlag = true;
    },
    onFakeReleased: function(){
        this.pressedFlag = false;
    },
    onCreateModule: function(){
        // implement in subclass
    },
    onModuleAdded: function(module) {
        // implement in subclass
    },
    onControlReady: function() {
        // implement in subclass
    }
});

/*
 * JCF Utility Library
 */
jcf.lib = {
    bind: function(func, scope){
        return function() {
            return func.apply(scope, arguments);
        };
    },
    browser: (function() {
        var ua = navigator.userAgent.toLowerCase(), res = {},
        match = /(webkit)[ \/]([\w.]+)/.exec(ua) || /(opera)(?:.*version)?[ \/]([\w.]+)/.exec(ua) ||
                /(msie) ([\w.]+)/.exec(ua) || ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+))?/.exec(ua) || [];
        res[match[1]] = true;
        res.version = match[2] || "0";
        res.safariMac = ua.indexOf('mac') != -1 && ua.indexOf('safari') != -1;
        return res;
    })(),
    getOffset: function (obj) {
        if (obj.getBoundingClientRect && !jcf.isWinPhoneDevice) {
            var scrollLeft = window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft;
            var scrollTop = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop;
            var clientLeft = document.documentElement.clientLeft || document.body.clientLeft || 0;
            var clientTop = document.documentElement.clientTop || document.body.clientTop || 0;
            return {
                top:Math.round(obj.getBoundingClientRect().top + scrollTop - clientTop),
                left:Math.round(obj.getBoundingClientRect().left + scrollLeft - clientLeft)
            };
        } else {
            var posLeft = 0, posTop = 0;
            while (obj.offsetParent) {posLeft += obj.offsetLeft; posTop += obj.offsetTop; obj = obj.offsetParent;}
            return {top:posTop,left:posLeft};
        }
    },
    getScrollTop: function() {
        return window.pageYOffset || document.documentElement.scrollTop;
    },
    getScrollLeft: function() {
        return window.pageXOffset || document.documentElement.scrollLeft;
    },
    getWindowWidth: function(){
        return document.compatMode=='CSS1Compat' ? document.documentElement.clientWidth : document.body.clientWidth;
    },
    getWindowHeight: function(){
        return document.compatMode=='CSS1Compat' ? document.documentElement.clientHeight : document.body.clientHeight;
    },
    getStyle: function(el, prop) {
        if (document.defaultView && document.defaultView.getComputedStyle) {
            return document.defaultView.getComputedStyle(el, null)[prop];
        } else if (el.currentStyle) {
            return el.currentStyle[prop];
        } else {
            return el.style[prop];
        }
    },
    getParent: function(obj, selector) {
        while(obj.parentNode && obj.parentNode != document.body) {
            if(obj.parentNode.tagName.toLowerCase() == selector.toLowerCase()) {
                return obj.parentNode;
            }
            obj = obj.parentNode;
        }
        return false;
    },
    isParent: function(parent, child) {
        while(child.parentNode) {
            if(child.parentNode === parent) {
                return true;
            }
            child = child.parentNode;
        }
        return false;
    },
    getLabelFor: function(object) {
        var parentLabel = jcf.lib.getParent(object,'label');
        if(parentLabel) {
            return parentLabel;
        } else if(object.id) {
            return jcf.lib.queryBySelector('label[for="' + object.id + '"]')[0];
        }
    },
    disableTextSelection: function(el){
        if (typeof el.onselectstart !== 'undefined') {
            el.onselectstart = function() {return false;};
        } else if(window.opera) {
            el.setAttribute('unselectable', 'on');
        } else {
            jcf.lib.addClass(el, jcf.baseOptions.unselectableClass);
        }
    },
    enableTextSelection: function(el) {
        if (typeof el.onselectstart !== 'undefined') {
            el.onselectstart = null;
        } else if(window.opera) {
            el.removeAttribute('unselectable');
        } else {
            jcf.lib.removeClass(el, jcf.baseOptions.unselectableClass);
        }
    },
    queryBySelector: function(selector, scope){
        if(typeof scope === 'string') {
            var result = [];
            var holders = this.getElementsBySelector(scope);
            for (var i = 0, contextNodes; i < holders.length; i++) {
                contextNodes = Array.prototype.slice.call(this.getElementsBySelector(selector, holders[i]));
                result = result.concat(contextNodes);
            }
            return result;
        } else {
            return this.getElementsBySelector(selector, scope);
        }
    },
    prevSibling: function(node) {
        while(node = node.previousSibling) if(node.nodeType == 1) break;
        return node;
    },
    nextSibling: function(node) {
        while(node = node.nextSibling) if(node.nodeType == 1) break;
        return node;
    },
    fireEvent: function(element,event) {
        if(element.dispatchEvent){
            var evt = document.createEvent('HTMLEvents');
            evt.initEvent(event, true, true );
            return !element.dispatchEvent(evt);
        }else if(document.createEventObject){
            var evt = document.createEventObject();
            return element.fireEvent('on'+event,evt);
        }
    },
    inherit: function(Child, Parent) {
        var F = function() { }
        F.prototype = Parent.prototype
        Child.prototype = new F()
        Child.prototype.constructor = Child
        Child.superclass = Parent.prototype
    },
    extend: function(obj) {
        for(var i = 1; i < arguments.length; i++) {
            for(var p in arguments[i]) {
                if(arguments[i].hasOwnProperty(p)) {
                    obj[p] = arguments[i][p];
                }
            }
        }
        return obj;
    },
    hasClass: function (obj,cname) {
        return (obj.className ? obj.className.match(new RegExp('(\\s|^)'+cname+'(\\s|$)')) : false);
    },
    addClass: function (obj,cname) {
        if (!this.hasClass(obj,cname)) obj.className += (!obj.className.length || obj.className.charAt(obj.className.length - 1) === ' ' ? '' : ' ') + cname;
    },
    removeClass: function (obj,cname) {
        if (this.hasClass(obj,cname)) obj.className=obj.className.replace(new RegExp('(\\s|^)'+cname+'(\\s|$)'),' ').replace(/\s+$/, '');
    },
    toggleClass: function(obj, cname, condition) {
        if(condition) this.addClass(obj, cname); else this.removeClass(obj, cname);
    },
    createElement: function(tagName, options) {
        var el = document.createElement(tagName);
        for(var p in options) {
            if(options.hasOwnProperty(p)) {
                switch (p) {
                    case 'class': el.className = options[p]; break;
                    case 'html': el.innerHTML = options[p]; break;
                    case 'style': this.setStyles(el, options[p]); break;
                    default: el.setAttribute(p, options[p]);
                }
            }
        }
        return el;
    },
    setStyles: function(el, styles) {
        for(var p in styles) {
            if(styles.hasOwnProperty(p)) {
                switch (p) {
                    case 'float': el.style.cssFloat = styles[p]; break;
                    case 'opacity': el.style.filter = 'progid:DXImageTransform.Microsoft.Alpha(opacity='+styles[p]*100+')'; el.style.opacity = styles[p]; break;
                    default: el.style[p] = (typeof styles[p] === 'undefined' ? 0 : styles[p]) + (typeof styles[p] === 'number' ? 'px' : '');
                }
            }
        }
        return el;
    },
    getInnerWidth: function(el) {
        return el.offsetWidth - (parseInt(this.getStyle(el,'paddingLeft')) || 0) - (parseInt(this.getStyle(el,'paddingRight')) || 0);
    },
    getInnerHeight: function(el) {
        return el.offsetHeight - (parseInt(this.getStyle(el,'paddingTop')) || 0) - (parseInt(this.getStyle(el,'paddingBottom')) || 0);
    },
    getAllClasses: function(cname, prefix, skip) {
        if(!skip) skip = '';
        if(!prefix) prefix = '';
        return cname ? cname.replace(new RegExp('(\\s|^)'+skip+'(\\s|$)'),' ').replace(/[\s]*([\S]+)+[\s]*/gi,prefix+"$1 ") : '';
    },
    getElementsBySelector: function(selector, scope) {
        if(typeof document.querySelectorAll === 'function') {
            return (scope || document).querySelectorAll(selector);
        }
        var selectors = selector.split(',');
        var resultList = [];
        for(var s = 0; s < selectors.length; s++) {
            var currentContext = [scope || document];
            var tokens = selectors[s].replace(/^\s+/,'').replace(/\s+$/,'').split(' ');
            for (var i = 0; i < tokens.length; i++) {
                token = tokens[i].replace(/^\s+/,'').replace(/\s+$/,'');
                if (token.indexOf('#') > -1) {
                    var bits = token.split('#'), tagName = bits[0], id = bits[1];
                    var element = document.getElementById(id);
                    if (tagName && element.nodeName.toLowerCase() != tagName) {
                        return [];
                    }
                    currentContext = [element];
                    continue;
                }
                if (token.indexOf('.') > -1) {
                    var bits = token.split('.'), tagName = bits[0] || '*', className = bits[1], found = [], foundCount = 0;
                    for (var h = 0; h < currentContext.length; h++) {
                        var elements;
                        if (tagName == '*') {
                            elements = currentContext[h].getElementsByTagName('*');
                        } else {
                            elements = currentContext[h].getElementsByTagName(tagName);
                        }
                        for (var j = 0; j < elements.length; j++) {
                            found[foundCount++] = elements[j];
                        }
                    }
                    currentContext = [];
                    var currentContextIndex = 0;
                    for (var k = 0; k < found.length; k++) {
                        if (found[k].className && found[k].className.match(new RegExp('(\\s|^)'+className+'(\\s|$)'))) {
                            currentContext[currentContextIndex++] = found[k];
                        }
                    }
                    continue;
                }
                if (token.match(/^(\w*)\[(\w+)([=~\|\^\$\*]?)=?"?([^"]*)"?\]$/)) {
                    var tagName = RegExp.$1 || '*', attrName = RegExp.$2, attrOperator = RegExp.$3, attrValue = RegExp.$4;
                    if(attrName.toLowerCase() == 'for' && this.browser.msie && this.browser.version < 8) {
                        attrName = 'htmlFor';
                    }
                    var found = [], foundCount = 0;
                    for (var h = 0; h < currentContext.length; h++) {
                        var elements;
                        if (tagName == '*') {
                            elements = currentContext[h].getElementsByTagName('*');
                        } else {
                            elements = currentContext[h].getElementsByTagName(tagName);
                        }
                        for (var j = 0; elements[j]; j++) {
                            found[foundCount++] = elements[j];
                        }
                    }
                    currentContext = [];
                    var currentContextIndex = 0, checkFunction;
                    switch (attrOperator) {
                        case '=': checkFunction = function(e) { return (e.getAttribute(attrName) == attrValue) }; break;
                        case '~': checkFunction = function(e) { return (e.getAttribute(attrName).match(new RegExp('(\\s|^)'+attrValue+'(\\s|$)'))) }; break;
                        case '|': checkFunction = function(e) { return (e.getAttribute(attrName).match(new RegExp('^'+attrValue+'-?'))) }; break;
                        case '^': checkFunction = function(e) { return (e.getAttribute(attrName).indexOf(attrValue) == 0) }; break;
                        case '$': checkFunction = function(e) { return (e.getAttribute(attrName).lastIndexOf(attrValue) == e.getAttribute(attrName).length - attrValue.length) }; break;
                        case '*': checkFunction = function(e) { return (e.getAttribute(attrName).indexOf(attrValue) > -1) }; break;
                        default : checkFunction = function(e) { return e.getAttribute(attrName) };
                    }
                    currentContext = [];
                    var currentContextIndex = 0;
                    for (var k = 0; k < found.length; k++) {
                        if (checkFunction(found[k])) {
                            currentContext[currentContextIndex++] = found[k];
                        }
                    }
                    continue;
                }
                tagName = token;
                var found = [], foundCount = 0;
                for (var h = 0; h < currentContext.length; h++) {
                    var elements = currentContext[h].getElementsByTagName(tagName);
                    for (var j = 0; j < elements.length; j++) {
                        found[foundCount++] = elements[j];
                    }
                }
                currentContext = found;
            }
            resultList = [].concat(resultList,currentContext);
        }
        return resultList;
    },
    scrollSize: (function(){
        var content, hold, sizeBefore, sizeAfter;
        function buildSizer(){
            if(hold) removeSizer();
            content = document.createElement('div');
            hold = document.createElement('div');
            hold.style.cssText = 'position:absolute;overflow:hidden;width:100px;height:100px';
            hold.appendChild(content);
            document.body.appendChild(hold);
        }
        function removeSizer(){
            document.body.removeChild(hold);
            hold = null;
        }
        function calcSize(vertical) {
            buildSizer();
            content.style.cssText = 'height:'+(vertical ? '100%' : '200px');
            sizeBefore = (vertical ? content.offsetHeight : content.offsetWidth);
            hold.style.overflow = 'scroll'; content.innerHTML = 1;
            sizeAfter = (vertical ? content.offsetHeight : content.offsetWidth);
            if(vertical && hold.clientHeight) sizeAfter = hold.clientHeight;
            removeSizer();
            return sizeBefore - sizeAfter;
        }
        return {
            getWidth:function(){
                return calcSize(false);
            },
            getHeight:function(){
                return calcSize(true)
            }
        }
    }()),
    domReady: function (handler){
        var called = false
        function ready() {
            if (called) return;
            called = true;
            handler();
        }
        if (document.addEventListener) {
            document.addEventListener("DOMContentLoaded", ready, false);
        } else if (document.attachEvent) {
            if (document.documentElement.doScroll && window == window.top) {
                function tryScroll(){
                    if (called) return
                    if (!document.body) return
                    try {
                        document.documentElement.doScroll("left")
                        ready()
                    } catch(e) {
                        setTimeout(tryScroll, 0)
                    }
                }
                tryScroll()
            }
            document.attachEvent("onreadystatechange", function(){
                if (document.readyState === "complete") {
                    ready()
                }
            })
        }
        if (window.addEventListener) window.addEventListener('load', ready, false)
        else if (window.attachEvent) window.attachEvent('onload', ready)
    },
    event: (function(){
        var guid = 0;
        function fixEvent(e) {
            e = e || window.event;
            if (e.isFixed) {
                return e;
            }
            e.isFixed = true; 
            e.preventDefault = e.preventDefault || function(){this.returnValue = false}
            e.stopPropagation = e.stopPropagation || function(){this.cancelBubble = true}
            if (!e.target) {
                e.target = e.srcElement
            }
            if (!e.relatedTarget && e.fromElement) {
                e.relatedTarget = e.fromElement == e.target ? e.toElement : e.fromElement;
            }
            if (e.pageX == null && e.clientX != null) {
                var html = document.documentElement, body = document.body;
                e.pageX = e.clientX + (html && html.scrollLeft || body && body.scrollLeft || 0) - (html.clientLeft || 0);
                e.pageY = e.clientY + (html && html.scrollTop || body && body.scrollTop || 0) - (html.clientTop || 0);
            }
            if (!e.which && e.button) {
                e.which = e.button & 1 ? 1 : (e.button & 2 ? 3 : (e.button & 4 ? 2 : 0));
            }
            if(e.type === "DOMMouseScroll" || e.type === 'mousewheel') {
                e.mWheelDelta = 0;
                if (e.wheelDelta) {
                    e.mWheelDelta = e.wheelDelta/120;
                } else if (e.detail) {
                    e.mWheelDelta = -e.detail/3;
                }
            }
            return e;
        }
        function commonHandle(event, customScope) {
            event = fixEvent(event);
            var handlers = this.events[event.type];
            for (var g in handlers) {
                var handler = handlers[g];
                var ret = handler.call(customScope || this, event);
                if (ret === false) {
                    event.preventDefault()
                    event.stopPropagation()
                }
            }
        }
        var publicAPI = {
            add: function(elem, type, handler, forcedScope) {
                // handle multiple events
                if(type.indexOf(' ') > -1) {
                    var eventList = type.split(' ');
                    for(var i = 0; i < eventList.length; i++) {
                        publicAPI.add(elem, eventList[i], handler, forcedScope);
                    }
                    return;
                }

                if (elem.setInterval && (elem != window && !elem.frameElement)) {
                    elem = window;
                }
                if (!handler.guid) {
                    handler.guid = ++guid;
                }
                if (!elem.events) {
                    elem.events = {};
                    elem.handle = function(event) {
                        return commonHandle.call(elem, event);
                    }
                }
                if (!elem.events[type]) {
                    elem.events[type] = {};
                    if (elem.addEventListener) elem.addEventListener(type, elem.handle, false);
                    else if (elem.attachEvent) elem.attachEvent("on" + type, elem.handle);
                    if(type === 'mousewheel') {
                        publicAPI.add(elem, 'DOMMouseScroll', handler, forcedScope);
                    }
                }
                var fakeHandler = jcf.lib.bind(handler, forcedScope);
                fakeHandler.guid = handler.guid;
                elem.events[type][handler.guid] = forcedScope ? fakeHandler : handler;
            },
            remove: function(elem, type, handler) {
                // handle multiple events
                if(type.indexOf(' ') > -1) {
                    var eventList = type.split(' ');
                    for(var i = 0; i < eventList.length; i++) {
                        publicAPI.remove(elem, eventList[i], handler);
                    }
                    return;
                }

                var handlers = elem.events && elem.events[type];
                if (!handlers) return;
                delete handlers[handler.guid];
                for(var any in handlers) return;
                if (elem.removeEventListener) elem.removeEventListener(type, elem.handle, false);
                else if (elem.detachEvent) elem.detachEvent("on" + type, elem.handle);
                delete elem.events[type];
                for (var any in elem.events) return;
                try {
                    delete elem.handle;
                    delete elem.events;
                } catch(e) {
                    if(elem.removeAttribute) {
                        elem.removeAttribute("handle");
                        elem.removeAttribute("events");
                    }
                }
                if(type === 'mousewheel') {
                    publicAPI.remove(elem, 'DOMMouseScroll', handler);
                }
            }
        }
        return publicAPI;
    }())
}

// custom select module
jcf.addModule({
    name:'select',
    selector:'select',
    defaultOptions: {
        useNativeDropOnMobileDevices: true,
        hideDropOnScroll: true,
        showNativeDrop: false,
        handleDropPosition: false,
        selectDropPosition: 'bottom', // or 'top'
        wrapperClass:'select-area',
        focusClass:'select-focus',
        dropActiveClass:'select-active',
        selectedClass:'item-selected',
        currentSelectedClass:'current-selected',
        disabledClass:'select-disabled',
        valueSelector:'span.center', 
        optGroupClass:'optgroup',
        openerSelector:'a.select-opener',       
        selectStructure:'<span class="left"></span><span class="center"></span><a class="select-opener"></a>',
        wrapperTag: 'span',
        classPrefix:'select-',
        dropMaxHeight: 200,
        dropFlippedClass: 'select-options-flipped',
        dropHiddenClass:'options-hidden',
        dropScrollableClass:'options-overflow',
        dropClass:'select-options',
        dropClassPrefix:'drop-',
        dropStructure:'<div class="drop-holder"><div class="drop-list"></div></div>',
        dropSelector:'div.drop-list'
    },
    checkElement: function(el){
        return (!el.size && !el.multiple);
    },
    setupWrapper: function(){
        jcf.lib.addClass(this.fakeElement, this.options.wrapperClass);
        this.realElement.parentNode.insertBefore(this.fakeElement, this.realElement.nextSibling);
        this.fakeElement.innerHTML = this.options.selectStructure;
        this.fakeElement.style.width = (this.realElement.offsetWidth > 0 ? this.realElement.offsetWidth + 'px' : 'auto');

        // show native drop if specified in options
        if(this.options.useNativeDropOnMobileDevices && (jcf.isTouchDevice || jcf.isWinPhoneDevice)) {
            this.options.showNativeDrop = true;
        }
        if(this.options.showNativeDrop) {
            this.fakeElement.appendChild(this.realElement);
            jcf.lib.removeClass(this.realElement, this.options.hiddenClass);
            jcf.lib.setStyles(this.realElement, {
                top:0,
                left:0,
                margin:0,
                padding:0,
                opacity:0,
                border:'none',
                position:'absolute',
                width: jcf.lib.getInnerWidth(this.fakeElement) - 1,
                height: jcf.lib.getInnerHeight(this.fakeElement) - 1
            });
            jcf.lib.event.add(this.realElement, jcf.eventPress, function(){
                this.realElement.title = '';
            }, this)
        }
        
        // create select body
        this.opener = jcf.lib.queryBySelector(this.options.openerSelector, this.fakeElement)[0];
        this.valueText = jcf.lib.queryBySelector(this.options.valueSelector, this.fakeElement)[0];
        jcf.lib.disableTextSelection(this.valueText);
        this.opener.jcf = this;

        if(!this.options.showNativeDrop) {
            this.createDropdown();
            this.refreshState();
            this.onControlReady(this);
            this.hideDropdown();
        } else {
            this.refreshState();
        }
        this.addEvents();
    },
    addEvents: function(){
        if(this.options.showNativeDrop) {
            jcf.lib.event.add(this.realElement, 'click', this.onChange, this);
        } else {
            jcf.lib.event.add(this.fakeElement, 'click', this.toggleDropdown, this);
        }
        jcf.lib.event.add(this.realElement, 'change', this.onChange, this);
    },
    onFakeClick: function() {
        // do nothing (drop toggles by toggleDropdown method)
    },
    onFocus: function(){
        jcf.modules[this.name].superclass.onFocus.apply(this, arguments);
        if(!this.options.showNativeDrop) {
            // Mac Safari Fix
            if(jcf.lib.browser.safariMac) {
                this.realElement.setAttribute('size','2');
            }
            jcf.lib.event.add(this.realElement, 'keydown', this.onKeyDown, this);
            if(jcf.activeControl && jcf.activeControl != this) {
                jcf.activeControl.hideDropdown();
                jcf.activeControl = this;
            }
        }
    },
    onBlur: function(){
        if(!this.options.showNativeDrop) {
            // Mac Safari Fix
            if(jcf.lib.browser.safariMac) {
                this.realElement.removeAttribute('size');
            }
            if(!this.isActiveDrop() || !this.isOverDrop()) {
                jcf.modules[this.name].superclass.onBlur.apply(this);
                if(jcf.activeControl === this) jcf.activeControl = null;
                if(!jcf.isTouchDevice) {
                    this.hideDropdown();
                }
            }
            jcf.lib.event.remove(this.realElement, 'keydown', this.onKeyDown);
        } else {
            jcf.modules[this.name].superclass.onBlur.apply(this);
        }
    },
    onChange: function() {
        this.refreshState();
    },
    onKeyDown: function(e){
        this.dropOpened = true;
        jcf.tmpFlag = true;
        setTimeout(function(){jcf.tmpFlag = false},100);
        var context = this;
        context.keyboardFix = true;
        setTimeout(function(){
            context.refreshState();
        },10);
        if(e.keyCode == 13) {
            context.toggleDropdown.apply(context);
            return false;
        }
    },
    onResizeWindow: function(e){
        if(this.isActiveDrop()) {
            this.hideDropdown();
        }
    },
    onScrollWindow: function(e){
        if(this.options.hideDropOnScroll) {
            this.hideDropdown();
        } else if(this.isActiveDrop()) {
            this.positionDropdown();
        }
    },
    onOptionClick: function(e){
        var opener = e.target && e.target.tagName && e.target.tagName.toLowerCase() == 'li' ? e.target : jcf.lib.getParent(e.target, 'li');
        if(opener) {
            this.dropOpened = true;
            this.realElement.selectedIndex = parseInt(opener.getAttribute('rel'));
            if(jcf.isTouchDevice) {
                this.onFocus();
            } else {
                this.realElement.focus();
            }
            this.refreshState();
            this.hideDropdown();
            jcf.lib.fireEvent(this.realElement, 'change');
        }
        return false;
    },
    onClickOutside: function(e){
        if(jcf.tmpFlag) {
            jcf.tmpFlag = false;
            return;
        }
        if(!jcf.lib.isParent(this.fakeElement, e.target) && !jcf.lib.isParent(this.selectDrop, e.target)) {
            this.hideDropdown();
        }
    },
    onDropHover: function(e){
        if(!this.keyboardFix) {
            this.hoverFlag = true;
            var opener = e.target && e.target.tagName && e.target.tagName.toLowerCase() == 'li' ? e.target : jcf.lib.getParent(e.target, 'li');
            if(opener) {
                this.realElement.selectedIndex = parseInt(opener.getAttribute('rel'));
                this.refreshSelectedClass(parseInt(opener.getAttribute('rel')));
            }
        } else {
            this.keyboardFix = false;
        }
    },
    onDropLeave: function(){
        this.hoverFlag = false;
    },
    isActiveDrop: function(){
        return !jcf.lib.hasClass(this.selectDrop, this.options.dropHiddenClass);
    },
    isOverDrop: function(){
        return this.hoverFlag;
    },
    createDropdown: function(){
        // remove old dropdown if exists
        if(this.selectDrop && this.selectDrop.parentNode) {
            this.selectDrop.parentNode.removeChild(this.selectDrop);
        }

        // create dropdown holder
        this.selectDrop = document.createElement('div');
        this.selectDrop.className = this.options.dropClass;
        this.selectDrop.innerHTML = this.options.dropStructure;
        jcf.lib.setStyles(this.selectDrop, {position:'absolute'});
        this.selectList = jcf.lib.queryBySelector(this.options.dropSelector,this.selectDrop)[0];
        jcf.lib.addClass(this.selectDrop, this.options.dropHiddenClass);
        document.body.appendChild(this.selectDrop);
        this.selectDrop.jcf = this;
        jcf.lib.event.add(this.selectDrop, 'click', this.onOptionClick, this);
        jcf.lib.event.add(this.selectDrop, 'mouseover', this.onDropHover, this);
        jcf.lib.event.add(this.selectDrop, 'mouseout', this.onDropLeave, this);
        this.buildDropdown();
    },
    buildDropdown: function() {
        // build select options / optgroups
        this.buildDropdownOptions();

        // position and resize dropdown
        this.positionDropdown();

        // cut dropdown if height exceedes
        this.buildDropdownScroll();
    },
    buildDropdownOptions: function() {
        this.resStructure = '';
        this.optNum = 0;
        for(var i = 0; i < this.realElement.children.length; i++) {
            this.resStructure += this.buildElement(this.realElement.children[i], i) +'\n';
        }
        this.selectList.innerHTML = this.resStructure;
    },
    buildDropdownScroll: function() {
        jcf.lib.addClass(this.selectDrop, jcf.lib.getAllClasses(this.realElement.className, this.options.dropClassPrefix, jcf.baseOptions.hiddenClass));
        if(this.options.dropMaxHeight) {
            if(this.selectDrop.offsetHeight > this.options.dropMaxHeight) {
                this.selectList.style.height = this.options.dropMaxHeight+'px';
                this.selectList.style.overflow = 'auto';
                this.selectList.style.overflowX = 'hidden';
                jcf.lib.addClass(this.selectDrop, this.options.dropScrollableClass);
            }
        }
    },
    parseOptionTitle: function(optTitle) {
        return (typeof optTitle === 'string' && /\.(jpg|gif|png|bmp|jpeg)(.*)?$/i.test(optTitle)) ? optTitle : '';
    },
    buildElement: function(obj, index){
        // build option
        var res = '', optImage;
        if(obj.tagName.toLowerCase() == 'option') {
            if(!jcf.lib.prevSibling(obj) || jcf.lib.prevSibling(obj).tagName.toLowerCase() != 'option') {
                res += '<ul>';
            }
            
            optImage = this.parseOptionTitle(obj.title);
            res += '<li rel="'+(this.optNum++)+'" class="'+(obj.className? obj.className + ' ' : '')+(index % 2 ? 'option-even ' : '')+'jcfcalc"><a href="#">'+(optImage ? '<img src="'+optImage+'" alt="" />' : '')+'<span>' + obj.innerHTML + '</span></a></li>';
            if(!jcf.lib.nextSibling(obj) || jcf.lib.nextSibling(obj).tagName.toLowerCase() != 'option') {
                res += '</ul>';
            }
            return res;
        }
        // build option group with options
        else if(obj.tagName.toLowerCase() == 'optgroup' && obj.label) {
            res += '<div class="'+this.options.optGroupClass+'">';
            res += '<strong class="jcfcalc"><em>'+(obj.label)+'</em></strong>';
            for(var i = 0; i < obj.children.length; i++) {
                res += this.buildElement(obj.children[i], i);
            }
            res += '</div>';
            return res;
        }
    },
    positionDropdown: function(){
        var ofs = jcf.lib.getOffset(this.fakeElement), selectAreaHeight = this.fakeElement.offsetHeight, selectDropHeight = this.selectDrop.offsetHeight;
        var fitInTop = ofs.top - selectDropHeight >= jcf.lib.getScrollTop() && jcf.lib.getScrollTop() + jcf.lib.getWindowHeight() < ofs.top + selectAreaHeight + selectDropHeight;
        
        
        if((this.options.handleDropPosition && fitInTop) || this.options.selectDropPosition === 'top') {
            this.selectDrop.style.top = (ofs.top - selectDropHeight)+'px';
            jcf.lib.addClass(this.selectDrop, this.options.dropFlippedClass);
            jcf.lib.addClass(this.fakeElement, this.options.dropFlippedClass);
        } else {
            this.selectDrop.style.top = (ofs.top + selectAreaHeight)+'px';
            jcf.lib.removeClass(this.selectDrop, this.options.dropFlippedClass);
            jcf.lib.removeClass(this.fakeElement, this.options.dropFlippedClass);
        }
        this.selectDrop.style.left = ofs.left+'px';
        this.selectDrop.style.width = this.fakeElement.offsetWidth+'px';
    },
    showDropdown: function(){
        document.body.appendChild(this.selectDrop);
        jcf.lib.removeClass(this.selectDrop, this.options.dropHiddenClass);
        jcf.lib.addClass(this.fakeElement,this.options.dropActiveClass);
        this.positionDropdown();

        // highlight current active item
        var activeItem = this.getFakeActiveOption();
        this.removeClassFromItems(this.options.currentSelectedClass);
        jcf.lib.addClass(activeItem, this.options.currentSelectedClass);
        
        // show current dropdown
        jcf.lib.event.add(window, 'resize', this.onResizeWindow, this);
        jcf.lib.event.add(window, 'scroll', this.onScrollWindow, this);
        jcf.lib.event.add(document, jcf.eventPress, this.onClickOutside, this);
        this.positionDropdown();
    },
    hideDropdown: function(){
        if(this.selectDrop.parentNode) {
            this.selectDrop.parentNode.removeChild(this.selectDrop);
        }
        if(typeof this.origSelectedIndex === 'number') {
            this.realElement.selectedIndex = this.origSelectedIndex;
        }
        jcf.lib.removeClass(this.fakeElement,this.options.dropActiveClass);
        jcf.lib.addClass(this.selectDrop, this.options.dropHiddenClass);
        jcf.lib.event.remove(window, 'resize', this.onResizeWindow);
        jcf.lib.event.remove(window, 'scroll', this.onScrollWindow);
        jcf.lib.event.remove(document.documentElement, jcf.eventPress, this.onClickOutside);
        if(jcf.isTouchDevice) {
            this.onBlur();
        }
    },
    toggleDropdown: function(){
        if(!this.realElement.disabled && this.realElement.options.length) {
            if(jcf.isTouchDevice) {
                this.onFocus();
            } else {
                this.realElement.focus();
            }
            if(this.isActiveDrop()) {
                this.hideDropdown();
            } else {
                this.showDropdown();
            }
            this.refreshState();
        }
    },
    scrollToItem: function(){
        if(this.isActiveDrop()) {
            var dropHeight = this.selectList.offsetHeight;
            var offsetTop = this.calcOptionOffset(this.getFakeActiveOption());
            var sTop = this.selectList.scrollTop;
            var oHeight = this.getFakeActiveOption().offsetHeight;
            //offsetTop+=sTop;

            if(offsetTop >= sTop + dropHeight) {
                this.selectList.scrollTop = offsetTop - dropHeight + oHeight;
            } else if(offsetTop < sTop) {
                this.selectList.scrollTop = offsetTop;
            }
        }
    },
    getFakeActiveOption: function(c) {
        return jcf.lib.queryBySelector('li[rel="'+(typeof c === 'number' ? c : this.realElement.selectedIndex) +'"]',this.selectList)[0];
    },
    calcOptionOffset: function(fake) {
        var h = 0;
        var els = jcf.lib.queryBySelector('.jcfcalc',this.selectList);
        for(var i = 0; i < els.length; i++) {
            if(els[i] == fake) break;
            h+=els[i].offsetHeight;
        }
        return h;
    },
    childrenHasItem: function(hold,item) {
        var items = hold.getElementsByTagName('*');
        for(i = 0; i < items.length; i++) {
            if(items[i] == item) return true;
        }
        return false;
    },
    removeClassFromItems: function(className){
        var children = jcf.lib.queryBySelector('li',this.selectList);
        for(var i = children.length - 1; i >= 0; i--) {
            jcf.lib.removeClass(children[i], className);
        }
    },
    setSelectedClass: function(c){
        var activeOption = this.getFakeActiveOption(c);
        if(activeOption) {
            jcf.lib.addClass(activeOption, this.options.selectedClass);
        }
    },
    refreshSelectedClass: function(c){
        if(!this.options.showNativeDrop) {
            this.removeClassFromItems(this.options.selectedClass);
            this.setSelectedClass(c);
        }
        if(this.realElement.disabled) {
            jcf.lib.addClass(this.fakeElement, this.options.disabledClass);
            if(this.labelFor) {
                jcf.lib.addClass(this.labelFor, this.options.labelDisabledClass);
            }
        } else {
            jcf.lib.removeClass(this.fakeElement, this.options.disabledClass);
            if(this.labelFor) {
                jcf.lib.removeClass(this.labelFor, this.options.labelDisabledClass);
            }
        }
    },
    refreshSelectedText: function() {
        if(!this.dropOpened && this.realElement.title) {
            this.valueText.innerHTML = this.realElement.title;
        } else {
            var activeOption = this.realElement.options[this.realElement.selectedIndex];
            if(activeOption) {
                if(activeOption.title) {
                    var optImage = this.parseOptionTitle(this.realElement.options[this.realElement.selectedIndex].title);
                    this.valueText.innerHTML = (optImage ? '<img src="'+optImage+'" alt="" />' : '') + this.realElement.options[this.realElement.selectedIndex].innerHTML;
                } else {
                    this.valueText.innerHTML = this.realElement.options[this.realElement.selectedIndex].innerHTML;
                }
            }
        }

        var selectedOption = this.realElement.options[this.realElement.selectedIndex];
        if(selectedOption && selectedOption.className) {
            this.fakeElement.setAttribute('data-option-class', jcf.lib.getAllClasses(selectedOption.className, 'option-').replace(/^\s+|\s+$/g, ''));
        } else {
            this.fakeElement.removeAttribute('data-option-class');
        }
    },
    refreshState: function(){
        this.origSelectedIndex = this.realElement.selectedIndex;
        this.refreshSelectedClass();
        this.refreshSelectedText();
        if(!this.options.showNativeDrop) {
            this.positionDropdown();
            if(this.selectDrop.offsetWidth) {
                this.scrollToItem();
            }
        }
    }
});

// custom radio module
jcf.addModule({
    name:'radio',
    selector: 'input[type="radio"]',
    defaultOptions: {
        wrapperClass:'rad-area',
        focusClass:'rad-focus',
        checkedClass:'rad-checked',
        uncheckedClass:'rad-unchecked',
        disabledClass:'rad-disabled',
        radStructure:'<span></span>'
    },
    getRadioGroup: function(item){
        var name = item.getAttribute('name');
        if(name) {
            return jcf.lib.queryBySelector('input[name="'+name+'"]', jcf.lib.getParent('form'));
        } else {
            return [item];
        }
    },
    setupWrapper: function(){
        jcf.lib.addClass(this.fakeElement, this.options.wrapperClass);
        this.fakeElement.innerHTML = this.options.radStructure;
        this.realElement.parentNode.insertBefore(this.fakeElement, this.realElement);
        this.refreshState();
        this.addEvents();
    },
    addEvents: function(){
        jcf.lib.event.add(this.fakeElement, 'click', this.toggleRadio, this);
        if(this.labelFor) {
            jcf.lib.event.add(this.labelFor, 'click', this.toggleRadio, this);
        }
    },
    onFocus: function(e) {
        jcf.modules[this.name].superclass.onFocus.apply(this, arguments);
        setTimeout(jcf.lib.bind(function(){
            this.refreshState();
        },this),10);
    },
    toggleRadio: function(){
        if(!this.realElement.disabled && !this.realElement.checked) {
            this.realElement.checked = true;
            jcf.lib.fireEvent(this.realElement, 'change');
        }
        this.refreshState();
    },
    refreshState: function(){
        var els = this.getRadioGroup(this.realElement);
        for(var i = 0; i < els.length; i++) {
            var curEl = els[i].jcf;
            if(curEl) {
                if(curEl.realElement.checked) {
                    jcf.lib.addClass(curEl.fakeElement, curEl.options.checkedClass);
                    jcf.lib.removeClass(curEl.fakeElement, curEl.options.uncheckedClass);
                    if(curEl.labelFor) {
                        jcf.lib.addClass(curEl.labelFor, curEl.options.labelActiveClass);
                    }
                } else {
                    jcf.lib.removeClass(curEl.fakeElement, curEl.options.checkedClass);
                    jcf.lib.addClass(curEl.fakeElement, curEl.options.uncheckedClass);
                    if(curEl.labelFor) {
                        jcf.lib.removeClass(curEl.labelFor, curEl.options.labelActiveClass);
                    }
                }
                if(curEl.realElement.disabled) {
                    jcf.lib.addClass(curEl.fakeElement, curEl.options.disabledClass);
                    if(curEl.labelFor) {
                        jcf.lib.addClass(curEl.labelFor, curEl.options.labelDisabledClass);
                    }
                } else {
                    jcf.lib.removeClass(curEl.fakeElement, curEl.options.disabledClass);
                    if(curEl.labelFor) {
                        jcf.lib.removeClass(curEl.labelFor, curEl.options.labelDisabledClass);
                    }
                }
            }
        }
    }
});


/*
 * Browser platform detection
 */
PlatformDetect = (function(){
    var detectModules = {};

    return {
        options: {
            cssPath: window.pathInfo ? pathInfo.base + pathInfo.css : 'css/'
        },
        addModule: function(obj) {
            detectModules[obj.type] = obj;
        },
        addRule: function(rule) {
            if(this.matchRule(rule)) {
                this.applyRule(rule);
                return true;
            }
        },
        matchRule: function(rule) {
            return detectModules[rule.type].matchRule(rule);
        },
        applyRule: function(rule) {
            var head = document.getElementsByTagName('head')[0], fragment, cssText;
            if(rule.css) {
                cssText = '<link rel="stylesheet" href="' + this.options.cssPath + rule.css + '" />';
                if(head) {
                    fragment = document.createElement('div');
                    fragment.innerHTML = cssText;
                    head.appendChild(fragment.childNodes[0]);
                } else {
                    document.write(cssText);
                }
            }
            
            if(rule.meta) {
                if(head) {
                    fragment = document.createElement('div');
                    fragment.innerHTML = rule.meta;
                    head.appendChild(fragment.childNodes[0]);
                } else {
                    document.write(rule.meta);
                }
            }
        },
        matchVersions: function(host, target) {
            target = target.toString();
            host = host.toString();

            var majorVersionMatch = parseInt(target, 10) === parseInt(host, 10);
            var minorVersionMatch = (host.length > target.length ? host.indexOf(target) : target.indexOf(host)) === 0;

            return majorVersionMatch && minorVersionMatch;
        }
    };
}());

// Windows Phone detection
PlatformDetect.addModule({
    type: 'winphone',
    parseUserAgent: function() {
        var match = /(Windows Phone OS) ([0-9.]*).*/.exec(navigator.userAgent);
        if(match) {
            return {
                version: match[2]
            };
        }
        if(/MSIE 10.*Touch/.test(navigator.userAgent)) {
            return {
                version: 8
            };
        }
    },
    matchRule: function(rule) {
        this.matchData = this.matchData || this.parseUserAgent();
        if(this.matchData) {
            return rule.version ? PlatformDetect.matchVersions(this.matchData.version, rule.version) : true;
        }
    }
});

// Detect rules
PlatformDetect.addRule({type: 'winphone', css: 'winphone.css'});

/*
 * Image Stretch module
 */
var ImageStretcher = {
    getDimensions: function(data) {
        // calculate element coords to fit in mask
        var ratio = data.imageRatio || (data.imageWidth / data.imageHeight),
            slideWidth = data.maskWidth,
            slideHeight = slideWidth / ratio;

        if(slideHeight < data.maskHeight) {
            slideHeight = data.maskHeight;
            slideWidth = slideHeight * ratio;
        }
        return {
            width: slideWidth,
            height: slideHeight,
            top: (data.maskHeight - slideHeight) / 2,
            left: (data.maskWidth - slideWidth) / 2
        };
    },
    getRatio: function(image) {
        if(image.prop('naturalWidth')) {
            return image.prop('naturalWidth') / image.prop('naturalHeight');
        } else {
            var img = new Image();
            img.src = image.prop('src');
            return img.width / img.height;
        }
    },
    imageLoaded: function(image, callback) {
        var self = this;
        var loadHandler = function() {
            callback.call(self);
        };
        if(image.prop('complete')) {
            loadHandler();
        } else {
            image.one('load', loadHandler);
        }
    },
    resizeHandler: function() {
        var self = this;
        jQuery.each(this.imgList, function(index, item) {
            if(item.image.prop('complete')) {
                self.resizeImage(item.image, item.container);
            }
        });
    },
    resizeImage: function(image, container) {
        this.imageLoaded(image, function() {
            var styles = this.getDimensions({
                imageRatio: this.getRatio(image),
                maskWidth: container.width(),
                maskHeight: container.height()
            });
            image.css({
                width: styles.width,
                height: styles.height,
                marginTop: styles.top,
                marginLeft: styles.left
            });
        });
    },
    add: function(options) {
        var container = jQuery(options.container ? options.container : window),
            image = typeof options.image === 'string' ? container.find(options.image) : jQuery(options.image);

        // resize image
        this.resizeImage(image, container);

        // add resize handler once if needed
        if(!this.win) {
            this.resizeHandler = jQuery.proxy(this.resizeHandler, this);
            this.imgList = [];
            this.win = jQuery(window);
            this.win.on('resize orientationchange', this.resizeHandler);
        }

        // store item in collection
        this.imgList.push({
            container: container,
            image: image
        });
    }
};

/*! Hammer.JS - v1.1.3 - 2014-05-20
 * http://eightmedia.github.io/hammer.js
 *
 * Copyright (c) 2014 Jorik Tangelder <j.tangelder@gmail.com>;
 * Licensed under the MIT license */
!function(a,b){"use strict";function c(){d.READY||(s.determineEventTypes(),r.each(d.gestures,function(a){u.register(a)}),s.onTouch(d.DOCUMENT,n,u.detect),s.onTouch(d.DOCUMENT,o,u.detect),d.READY=!0)}var d=function v(a,b){return new v.Instance(a,b||{})};d.VERSION="1.1.3",d.defaults={behavior:{userSelect:"none",touchAction:"pan-y",touchCallout:"none",contentZooming:"none",userDrag:"none",tapHighlightColor:"rgba(0,0,0,0)"}},d.DOCUMENT=document,d.HAS_POINTEREVENTS=navigator.pointerEnabled||navigator.msPointerEnabled,d.HAS_TOUCHEVENTS="ontouchstart"in a,d.IS_MOBILE=/mobile|tablet|ip(ad|hone|od)|android|silk/i.test(navigator.userAgent),d.NO_MOUSEEVENTS=d.HAS_TOUCHEVENTS&&d.IS_MOBILE||d.HAS_POINTEREVENTS,d.CALCULATE_INTERVAL=25;var e={},f=d.DIRECTION_DOWN="down",g=d.DIRECTION_LEFT="left",h=d.DIRECTION_UP="up",i=d.DIRECTION_RIGHT="right",j=d.POINTER_MOUSE="mouse",k=d.POINTER_TOUCH="touch",l=d.POINTER_PEN="pen",m=d.EVENT_START="start",n=d.EVENT_MOVE="move",o=d.EVENT_END="end",p=d.EVENT_RELEASE="release",q=d.EVENT_TOUCH="touch";d.READY=!1,d.plugins=d.plugins||{},d.gestures=d.gestures||{};var r=d.utils={extend:function(a,c,d){for(var e in c)!c.hasOwnProperty(e)||a[e]!==b&&d||(a[e]=c[e]);return a},on:function(a,b,c){a.addEventListener(b,c,!1)},off:function(a,b,c){a.removeEventListener(b,c,!1)},each:function(a,c,d){var e,f;if("forEach"in a)a.forEach(c,d);else if(a.length!==b){for(e=0,f=a.length;f>e;e++)if(c.call(d,a[e],e,a)===!1)return}else for(e in a)if(a.hasOwnProperty(e)&&c.call(d,a[e],e,a)===!1)return},inStr:function(a,b){return a.indexOf(b)>-1},inArray:function(a,b){if(a.indexOf){var c=a.indexOf(b);return-1===c?!1:c}for(var d=0,e=a.length;e>d;d++)if(a[d]===b)return d;return!1},toArray:function(a){return Array.prototype.slice.call(a,0)},hasParent:function(a,b){for(;a;){if(a==b)return!0;a=a.parentNode}return!1},getCenter:function(a){var b=[],c=[],d=[],e=[],f=Math.min,g=Math.max;return 1===a.length?{pageX:a[0].pageX,pageY:a[0].pageY,clientX:a[0].clientX,clientY:a[0].clientY}:(r.each(a,function(a){b.push(a.pageX),c.push(a.pageY),d.push(a.clientX),e.push(a.clientY)}),{pageX:(f.apply(Math,b)+g.apply(Math,b))/2,pageY:(f.apply(Math,c)+g.apply(Math,c))/2,clientX:(f.apply(Math,d)+g.apply(Math,d))/2,clientY:(f.apply(Math,e)+g.apply(Math,e))/2})},getVelocity:function(a,b,c){return{x:Math.abs(b/a)||0,y:Math.abs(c/a)||0}},getAngle:function(a,b){var c=b.clientX-a.clientX,d=b.clientY-a.clientY;return 180*Math.atan2(d,c)/Math.PI},getDirection:function(a,b){var c=Math.abs(a.clientX-b.clientX),d=Math.abs(a.clientY-b.clientY);return c>=d?a.clientX-b.clientX>0?g:i:a.clientY-b.clientY>0?h:f},getDistance:function(a,b){var c=b.clientX-a.clientX,d=b.clientY-a.clientY;return Math.sqrt(c*c+d*d)},getScale:function(a,b){return a.length>=2&&b.length>=2?this.getDistance(b[0],b[1])/this.getDistance(a[0],a[1]):1},getRotation:function(a,b){return a.length>=2&&b.length>=2?this.getAngle(b[1],b[0])-this.getAngle(a[1],a[0]):0},isVertical:function(a){return a==h||a==f},setPrefixedCss:function(a,b,c,d){var e=["","Webkit","Moz","O","ms"];b=r.toCamelCase(b);for(var f=0;f<e.length;f++){var g=b;if(e[f]&&(g=e[f]+g.slice(0,1).toUpperCase()+g.slice(1)),g in a.style){a.style[g]=(null==d||d)&&c||"";break}}},toggleBehavior:function(a,b,c){if(b&&a&&a.style){r.each(b,function(b,d){r.setPrefixedCss(a,d,b,c)});var d=c&&function(){return!1};"none"==b.userSelect&&(a.onselectstart=d),"none"==b.userDrag&&(a.ondragstart=d)}},toCamelCase:function(a){return a.replace(/[_-]([a-z])/g,function(a){return a[1].toUpperCase()})}},s=d.event={preventMouseEvents:!1,started:!1,shouldDetect:!1,on:function(a,b,c,d){var e=b.split(" ");r.each(e,function(b){r.on(a,b,c),d&&d(b)})},off:function(a,b,c,d){var e=b.split(" ");r.each(e,function(b){r.off(a,b,c),d&&d(b)})},onTouch:function(a,b,c){var f=this,g=function(e){var g,h=e.type.toLowerCase(),i=d.HAS_POINTEREVENTS,j=r.inStr(h,"mouse");j&&f.preventMouseEvents||(j&&b==m&&0===e.button?(f.preventMouseEvents=!1,f.shouldDetect=!0):i&&b==m?f.shouldDetect=1===e.buttons||t.matchType(k,e):j||b!=m||(f.preventMouseEvents=!0,f.shouldDetect=!0),i&&b!=o&&t.updatePointer(b,e),f.shouldDetect&&(g=f.doDetect.call(f,e,b,a,c)),g==o&&(f.preventMouseEvents=!1,f.shouldDetect=!1,t.reset()),i&&b==o&&t.updatePointer(b,e))};return this.on(a,e[b],g),g},doDetect:function(a,b,c,d){var e=this.getTouchList(a,b),f=e.length,g=b,h=e.trigger,i=f;b==m?h=q:b==o&&(h=p,i=e.length-(a.changedTouches?a.changedTouches.length:1)),i>0&&this.started&&(g=n),this.started=!0;var j=this.collectEventData(c,g,e,a);return b!=o&&d.call(u,j),h&&(j.changedLength=i,j.eventType=h,d.call(u,j),j.eventType=g,delete j.changedLength),g==o&&(d.call(u,j),this.started=!1),g},determineEventTypes:function(){var b;return b=d.HAS_POINTEREVENTS?a.PointerEvent?["pointerdown","pointermove","pointerup pointercancel lostpointercapture"]:["MSPointerDown","MSPointerMove","MSPointerUp MSPointerCancel MSLostPointerCapture"]:d.NO_MOUSEEVENTS?["touchstart","touchmove","touchend touchcancel"]:["touchstart mousedown","touchmove mousemove","touchend touchcancel mouseup"],e[m]=b[0],e[n]=b[1],e[o]=b[2],e},getTouchList:function(a,b){if(d.HAS_POINTEREVENTS&&!(navigator.msPointerEnabled&&!navigator.pointerEnabled))return t.getTouchList();if(a.touches){if(b==n)return a.touches;var c=[],e=[].concat(r.toArray(a.touches),r.toArray(a.changedTouches)),f=[];return r.each(e,function(a){r.inArray(c,a.identifier)===!1&&f.push(a),c.push(a.identifier)}),f}return a.identifier=1,[a]},collectEventData:function(a,b,c,d){var e=k;return r.inStr(d.type,"mouse")||t.matchType(j,d)?e=j:t.matchType(l,d)&&(e=l),{center:r.getCenter(c),timeStamp:Date.now(),target:d.target,touches:c,eventType:b,pointerType:e,srcEvent:d,preventDefault:function(){var a=this.srcEvent;a.preventManipulation&&a.preventManipulation(),a.preventDefault&&a.preventDefault()},stopPropagation:function(){this.srcEvent.stopPropagation()},stopDetect:function(){return u.stopDetect()}}}},t=d.PointerEvent={pointers:{},getTouchList:function(){var a=[];return r.each(this.pointers,function(b){a.push(b)}),a},updatePointer:function(a,b){a==o||a!=o&&1!==b.buttons?delete this.pointers[b.pointerId]:(b.identifier=b.pointerId,this.pointers[b.pointerId]=b)},matchType:function(a,b){if(!b.pointerType)return!1;var c=b.pointerType,d={};return d[j]=c===(b.MSPOINTER_TYPE_MOUSE||j),d[k]=c===(b.MSPOINTER_TYPE_TOUCH||k),d[l]=c===(b.MSPOINTER_TYPE_PEN||l),d[a]},reset:function(){this.pointers={}}},u=d.detection={gestures:[],current:null,previous:null,stopped:!1,startDetect:function(a,b){this.current||(this.stopped=!1,this.current={inst:a,startEvent:r.extend({},b),lastEvent:!1,lastCalcEvent:!1,futureCalcEvent:!1,lastCalcData:{},name:""},this.detect(b))},detect:function(a){if(this.current&&!this.stopped){a=this.extendEventData(a);var b=this.current.inst,c=b.options;return r.each(this.gestures,function(d){!this.stopped&&b.enabled&&c[d.name]&&d.handler.call(d,a,b)},this),this.current&&(this.current.lastEvent=a),a.eventType==o&&this.stopDetect(),a}},stopDetect:function(){this.previous=r.extend({},this.current),this.current=null,this.stopped=!0},getCalculatedData:function(a,b,c,e,f){var g=this.current,h=!1,i=g.lastCalcEvent,j=g.lastCalcData;i&&a.timeStamp-i.timeStamp>d.CALCULATE_INTERVAL&&(b=i.center,c=a.timeStamp-i.timeStamp,e=a.center.clientX-i.center.clientX,f=a.center.clientY-i.center.clientY,h=!0),(a.eventType==q||a.eventType==p)&&(g.futureCalcEvent=a),(!g.lastCalcEvent||h)&&(j.velocity=r.getVelocity(c,e,f),j.angle=r.getAngle(b,a.center),j.direction=r.getDirection(b,a.center),g.lastCalcEvent=g.futureCalcEvent||a,g.futureCalcEvent=a),a.velocityX=j.velocity.x,a.velocityY=j.velocity.y,a.interimAngle=j.angle,a.interimDirection=j.direction},extendEventData:function(a){var b=this.current,c=b.startEvent,d=b.lastEvent||c;(a.eventType==q||a.eventType==p)&&(c.touches=[],r.each(a.touches,function(a){c.touches.push({clientX:a.clientX,clientY:a.clientY})}));var e=a.timeStamp-c.timeStamp,f=a.center.clientX-c.center.clientX,g=a.center.clientY-c.center.clientY;return this.getCalculatedData(a,d.center,e,f,g),r.extend(a,{startEvent:c,deltaTime:e,deltaX:f,deltaY:g,distance:r.getDistance(c.center,a.center),angle:r.getAngle(c.center,a.center),direction:r.getDirection(c.center,a.center),scale:r.getScale(c.touches,a.touches),rotation:r.getRotation(c.touches,a.touches)}),a},register:function(a){var c=a.defaults||{};return c[a.name]===b&&(c[a.name]=!0),r.extend(d.defaults,c,!0),a.index=a.index||1e3,this.gestures.push(a),this.gestures.sort(function(a,b){return a.index<b.index?-1:a.index>b.index?1:0}),this.gestures}};d.Instance=function(a,b){var e=this;c(),this.element=a,this.enabled=!0,r.each(b,function(a,c){delete b[c],b[r.toCamelCase(c)]=a}),this.options=r.extend(r.extend({},d.defaults),b||{}),this.options.behavior&&r.toggleBehavior(this.element,this.options.behavior,!0),this.eventStartHandler=s.onTouch(a,m,function(a){e.enabled&&a.eventType==m?u.startDetect(e,a):a.eventType==q&&u.detect(a)}),this.eventHandlers=[]},d.Instance.prototype={on:function(a,b){var c=this;return s.on(c.element,a,b,function(a){c.eventHandlers.push({gesture:a,handler:b})}),c},off:function(a,b){var c=this;return s.off(c.element,a,b,function(a){var d=r.inArray({gesture:a,handler:b});d!==!1&&c.eventHandlers.splice(d,1)}),c},trigger:function(a,b){b||(b={});var c=d.DOCUMENT.createEvent("Event");c.initEvent(a,!0,!0),c.gesture=b;var e=this.element;return r.hasParent(b.target,e)&&(e=b.target),e.dispatchEvent(c),this},enable:function(a){return this.enabled=a,this},dispose:function(){var a,b;for(r.toggleBehavior(this.element,this.options.behavior,!1),a=-1;b=this.eventHandlers[++a];)r.off(this.element,b.gesture,b.handler);return this.eventHandlers=[],s.off(this.element,e[m],this.eventStartHandler),null}},function(a){function b(b,d){var e=u.current;if(!(d.options.dragMaxTouches>0&&b.touches.length>d.options.dragMaxTouches))switch(b.eventType){case m:c=!1;break;case n:if(b.distance<d.options.dragMinDistance&&e.name!=a)return;var j=e.startEvent.center;if(e.name!=a&&(e.name=a,d.options.dragDistanceCorrection&&b.distance>0)){var k=Math.abs(d.options.dragMinDistance/b.distance);j.pageX+=b.deltaX*k,j.pageY+=b.deltaY*k,j.clientX+=b.deltaX*k,j.clientY+=b.deltaY*k,b=u.extendEventData(b)}(e.lastEvent.dragLockToAxis||d.options.dragLockToAxis&&d.options.dragLockMinDistance<=b.distance)&&(b.dragLockToAxis=!0);var l=e.lastEvent.direction;b.dragLockToAxis&&l!==b.direction&&(b.direction=r.isVertical(l)?b.deltaY<0?h:f:b.deltaX<0?g:i),c||(d.trigger(a+"start",b),c=!0),d.trigger(a,b),d.trigger(a+b.direction,b);var q=r.isVertical(b.direction);(d.options.dragBlockVertical&&q||d.options.dragBlockHorizontal&&!q)&&b.preventDefault();break;case p:c&&b.changedLength<=d.options.dragMaxTouches&&(d.trigger(a+"end",b),c=!1);break;case o:c=!1}}var c=!1;d.gestures.Drag={name:a,index:50,handler:b,defaults:{dragMinDistance:10,dragDistanceCorrection:!0,dragMaxTouches:1,dragBlockHorizontal:!1,dragBlockVertical:!1,dragLockToAxis:!1,dragLockMinDistance:25}}}("drag"),d.gestures.Gesture={name:"gesture",index:1337,handler:function(a,b){b.trigger(this.name,a)}},function(a){function b(b,d){var e=d.options,f=u.current;switch(b.eventType){case m:clearTimeout(c),f.name=a,c=setTimeout(function(){f&&f.name==a&&d.trigger(a,b)},e.holdTimeout);break;case n:b.distance>e.holdThreshold&&clearTimeout(c);break;case p:clearTimeout(c)}}var c;d.gestures.Hold={name:a,index:10,defaults:{holdTimeout:500,holdThreshold:2},handler:b}}("hold"),d.gestures.Release={name:"release",index:1/0,handler:function(a,b){a.eventType==p&&b.trigger(this.name,a)}},d.gestures.Swipe={name:"swipe",index:40,defaults:{swipeMinTouches:1,swipeMaxTouches:1,swipeVelocityX:.6,swipeVelocityY:.6},handler:function(a,b){if(a.eventType==p){var c=a.touches.length,d=b.options;if(c<d.swipeMinTouches||c>d.swipeMaxTouches)return;(a.velocityX>d.swipeVelocityX||a.velocityY>d.swipeVelocityY)&&(b.trigger(this.name,a),b.trigger(this.name+a.direction,a))}}},function(a){function b(b,d){var e,f,g=d.options,h=u.current,i=u.previous;switch(b.eventType){case m:c=!1;break;case n:c=c||b.distance>g.tapMaxDistance;break;case o:!r.inStr(b.srcEvent.type,"cancel")&&b.deltaTime<g.tapMaxTime&&!c&&(e=i&&i.lastEvent&&b.timeStamp-i.lastEvent.timeStamp,f=!1,i&&i.name==a&&e&&e<g.doubleTapInterval&&b.distance<g.doubleTapDistance&&(d.trigger("doubletap",b),f=!0),(!f||g.tapAlways)&&(h.name=a,d.trigger(h.name,b)))}}var c=!1;d.gestures.Tap={name:a,index:100,handler:b,defaults:{tapMaxTime:250,tapMaxDistance:10,tapAlways:!0,doubleTapDistance:20,doubleTapInterval:300}}}("tap"),d.gestures.Touch={name:"touch",index:-1/0,defaults:{preventDefault:!1,preventMouse:!1},handler:function(a,b){return b.options.preventMouse&&a.pointerType==j?void a.stopDetect():(b.options.preventDefault&&a.preventDefault(),void(a.eventType==q&&b.trigger("touch",a)))}},function(a){function b(b,d){switch(b.eventType){case m:c=!1;break;case n:if(b.touches.length<2)return;var e=Math.abs(1-b.scale),f=Math.abs(b.rotation);if(e<d.options.transformMinScale&&f<d.options.transformMinRotation)return;u.current.name=a,c||(d.trigger(a+"start",b),c=!0),d.trigger(a,b),f>d.options.transformMinRotation&&d.trigger("rotate",b),e>d.options.transformMinScale&&(d.trigger("pinch",b),d.trigger("pinch"+(b.scale<1?"in":"out"),b));break;case p:c&&b.changedLength<2&&(d.trigger(a+"end",b),c=!1)}}var c=!1;d.gestures.Transform={name:a,index:45,defaults:{transformMinScale:.01,transformMinRotation:1},handler:b}}("transform"),"function"==typeof define&&define.amd?define(function(){return d}):"undefined"!=typeof module&&module.exports?module.exports=d:a.Hammer=d}(window);

/*! matchMedia() polyfill - Test a CSS media type/query in JS. Authors & copyright (c) 2012: Scott Jehl, Paul Irish, Nicholas Zakas. Dual MIT/BSD license */
;window.matchMedia=window.matchMedia||(function(e,f){var c,a=e.documentElement,b=a.firstElementChild||a.firstChild,d=e.createElement("body"),g=e.createElement("div");g.id="mq-test-1";g.style.cssText="position:absolute;top:-100em";d.appendChild(g);return function(h){g.innerHTML='&shy;<style media="'+h+'"> #mq-test-1 { width: 42px; }</style>';a.insertBefore(d,b);c=g.offsetWidth==42;a.removeChild(d);return{matches:c,media:h}}})(document);

/*! Picturefill - Responsive Images that work today. (and mimic the proposed Picture element with span elements). Author: Scott Jehl, Filament Group, 2012 | License: MIT/GPLv2 */
;(function(a){a.picturefill=function(){var b=a.document.getElementsByTagName("span");for(var f=0,l=b.length;f<l;f++){if(b[f].getAttribute("data-picture")!==null){var c=b[f].getElementsByTagName("span"),h=[];for(var e=0,g=c.length;e<g;e++){var d=c[e].getAttribute("data-media");if(!d||(a.matchMedia&&a.matchMedia(d).matches)){h.push(c[e])}}var m=b[f].getElementsByTagName("img")[0];if(h.length){var k=h.pop();if(!m||m.parentNode.nodeName==="NOSCRIPT"){m=a.document.createElement("img");m.alt=b[f].getAttribute("data-alt")}if(k.getAttribute("data-width")){m.setAttribute("width",k.getAttribute("data-width"))}else{m.removeAttribute("width")}if(k.getAttribute("data-height")){m.setAttribute("height",k.getAttribute("data-height"))}else{m.removeAttribute("height")}m.src=k.getAttribute("data-src");k.appendChild(m)}else{if(m){m.parentNode.removeChild(m)}}}}};if(a.addEventListener){a.addEventListener("resize",a.picturefill,false);a.addEventListener("DOMContentLoaded",function(){a.picturefill();a.removeEventListener("load",a.picturefill,false)},false);a.addEventListener("load",a.picturefill,false)}else{if(a.attachEvent){a.attachEvent("onload",a.picturefill)}}}(this));
