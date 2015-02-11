last_lat_time = Date.now();
last_lng_time = Date.now();
last_lat = 0;
last_lng = 0;
var requestSubstitution;

var interval;

var setCountDown = function (time) {
    if (time > 0) {
        var minutes = Math.floor(time / 60);
        var seconds = time - minutes * 60;
        var minuteText = '00';

        setInterval(function () {
            $('#counter-text').fadeIn('slow');
        }, 1000);

        interval = setInterval(function () {
            var counter = $('#counter');
            if (seconds == 0) {
                if (minutes == 0) {
                    clearInterval(interval);
                    location.reload();
                    return;
                } else {
                    minutes--;
                    seconds = 60;
                }
            }
            if (minutes > 0) {
                 minuteText = minutes < 10 ? '0' + minutes : minutes;
            } else {
                minuteText = '00';
            }
            var secondText = seconds < 10 ? '0' + seconds : seconds;
            counter.html(minuteText + ':' + secondText);
            seconds--;
        }, 1000);
    }
};

var ready = function () {
    if ($('body.orders').length && typeof(orderId) !== 'undefined') {
        var currentStatus = '';

        var checkOrderStatus = function () {

            if (orderId) {
                $.get('/orders/' + orderId + '/status', function (data) {

                    switch (data.status) {
                        case 'pending':
                            setOrderView('order-placed');
                            break;
                        case 'advised':
                            if (orderData.status !== 'advised') {
                                location.reload();
                            } else {
                                setOrderView('order-advised');
                            }
                            break;
                        case 'packing':
                            if (orderData.status !== 'packing') {
                                location.reload();
                            } else {
                                setOrderView('order-advised');
                            }
                            break;
                        case 'pickup':
                            setOrderView('order-pickup');
                            break;
                        case 'in transit':
                            setOrderView('order-in-transit');
                            renderMap(data);
                            break;
                        case 'delivered':
                            setOrderView('order-delivered');
                            clearInterval(scheduleCheckOrderStatus);
                            break;
                        case 'payment failed':
                            setOrderView('order-payment-failed');
                            break;
                        default:
                            setOrderView('order-placed');
                            break;
                    }
                });
            }

        };

        var setOrderView = function (status) {
            if (currentStatus === '') {
                currentStatus = status;
                resetViews();
                $('#' + status).addClass('active');
            } else if (currentStatus !== status) {
                currentStatus = status;
                resetViews();
                $('#' + status).addClass('active');
            }
        };

        var resetViews = function () {
            $('#order-placed').removeClass('active');
            $('#order-pickup').removeClass('active');
            $('#order-in-transit').removeClass('active');
            $('#order-delivered').removeClass('active');
            $('#order-advised').removeClass('active');
            $('#order-payment-failed').removeClass('active');
        };

        var scheduleCheckOrderStatus = setInterval(function () {
            checkOrderStatus();
        }, 10000);

        setCountDown(orderChangeTimeOutSeconds);

        var map;
        var wineMarker;

        var renderMap = function (data) {

            if (!map) {
                $('#map').show();
                map = L.map('map', {zoomControl: false});

                map.addControl(L.control.zoom({position: 'topright'}));

                var gl = new L.Google('ROAD');
                map.addLayer(gl);

                var warehouseIcon = L.icon({
                    iconUrl: '/winebar.png',
                    iconSize: [32, 32]
                });
                L.marker([data.warehouse_lat, data.warehouse_lng], {icon: warehouseIcon}).addTo(map);

                var homeIcon = L.icon({
                    iconUrl: '/home.png',
                    iconSize: [32, 32]
                });
                L.marker([data.customer_lat, data.customer_lng], {icon: homeIcon}).addTo(map);

                var directionsService = new google.maps.DirectionsService();

                var request = {
                    origin: new google.maps.LatLng(data.warehouse_lat, data.warehouse_lng),
                    destination: new google.maps.LatLng(data.customer_lat, data.customer_lng),
                    travelMode: google.maps.TravelMode.BICYCLING
                };

                directionsService.route(request, function (result, status) {
                    if (result && result.routes && result.routes.length) {

                        var line_points = [];

                        $.each(result.routes[0].overview_path, function (i, val) {
                            line_points[line_points.length] = [val.lat(), val.lng()];
                        });

                        var polyline = L.polyline(line_points, {color: 'blue'}).addTo(map);

                        map.fitBounds(polyline.getBounds());
                    }
                });

            }

            $.get('/delivery/get_courier_location?id=' + orderId, function (data) {

                if (data.data.lat !== last_lat) {
                    last_lat = data.data.lat;
                    last_lat_time = Date.now();
                }

                if (data.data.lng !== last_lng) {
                    last_lng = data.data.lng;
                    last_lng_time = Date.now();
                }

                if (!wineMarker) {
                    var bottleIcon = L.icon({
                        iconUrl: '/wine-bottle.png',
                        iconRetinaUrl: '/wine-bottle@2x.png',
                        iconSize: [32, 32]
                    });
                    wineMarker = L.marker([data.data.lat, data.data.lng], {icon: bottleIcon}).addTo(map);
                } else {

                    if (typeof(debug_location) !== 'undefined') {
                        console.log(data.data.lat);
                        console.log(Date.now() - last_lat_time);
                        console.log(data.data.lng);
                        console.log(Date.now() - last_lng_time);
                    }


                    wineMarker.setLatLng(L.latLng(
                            data.data.lat,
                            data.data.lng)
                    );
                }
            });

        };

        if(orderData && (orderData.status === 'advised' || orderData.status === 'packing')) {
            $("[name='wine-more-details-link']").click(function (e) {
                e.preventDefault();
                var id = $(this).data("id");
                $('#wine-summary-' + id).fadeToggle("slow", function() {
                    $('#wine-detail-' + id).fadeToggle("slow");
                });
            });

            $("[name='wine-less-details-link']").click(function (e) {
                e.preventDefault();
                var id = $(this).data("id");
                $('#wine-detail-' + id).fadeToggle("slow", function() {
                    $('#wine-summary-' + id).fadeToggle("slow");
                });
            });


        }

        if (orderData && orderData.status === 'in transit') {
            renderMap(orderData);
        }

        var $acceptOrder = $('#accept-order');
        var $processingOrder = $('.processing-order');



        $acceptOrder.click(function(e) {
            e.preventDefault();
            $.get('/orders/' +  orderId + '/accept' , function (data) {
                if(data.success) {
                    $('.can-edit-order').slideToggle(function() {
                        $processingOrder.slideDown();
                        var checkOrder = setInterval(function () {
                            checkOrderStatus();
                            clearInterval(checkOrder);
                        }, 4000);
                    });
                }
            });
        });
    }

    if ($('body.orders').length && typeof(substitutionOrderId) !== 'undefined') {

        setCountDown(orderChangeTimeOutSeconds);

        var substitutions = [];

        requestSubstitution = function(itemId) {

            $('#error').hide();
            $('#substitution-reason-' + itemId).toggle();
            var $link = $('#request-' + itemId);
            if ($link.val() === 'Change') {
                substitutions.push(itemId);
                $link.val('Cancel');
            } else {
                $link.val('Change');
                var index = $.inArray(itemId, substitutions);
                if (index > -1) {
                    $('#reason-error-' + itemId).hide();
                    substitutions.splice(index, 1);
                }
            }
        };

        $('#substitutions-form').submit(function (e) {

            var substitutionsAndReasons = [];
            var errors = [];

            e.preventDefault();
            $(substitutions).each(function () {
                var reason = $('#substitution-reason-' + this);

                if (reason.val().trim() === '') {
                    errors.push($('#reason-error-' + this));
                }

                substitutionsAndReasons.push({
                    id: this,
                    reason: reason.val()
                });
            });

            if (errors.length > 0) {
                $.each(errors, function () {
                    this.show();
                });

            } else if (substitutions.length === 0) {
                $('#error').show();
            }
            else {
                $('#substitutions').val(JSON.stringify(substitutionsAndReasons))
                this.submit();
            }
        });
    }

    if ($('body.orders').length && typeof(cancellationOrderId) !== 'undefined') {

        setCountDown(orderChangeTimeOutSeconds);
        setInterval(function () {
            $('#counter-text').fadeIn('slow');
        }, 1000);

        $('#cancel-order').submit(function (e) {
            e.preventDefault();
            if ($('#reason').val().trim() === '') {
                $('#cancel-error').show();
            } else {
                this.submit();
            }
        });

    }

};

$(document).on('page:load', ready);
$(document).ready(ready);