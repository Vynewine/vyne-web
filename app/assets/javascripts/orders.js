last_lat_time = Date.now();
last_lng_time = Date.now();
last_lat = 0;
last_lng = 0;

var interval;

var setCountDown = function (time) {
    if (time > 0) {
        var minutes = Math.floor(time / 60);
        var seconds = time - minutes * 60;

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
                var minute_text = minutes < 10 ? '0' + minutes : minutes;
            } else {
                var minute_text = '00';
            }
            var second_text = seconds < 10 ? '0' + seconds : seconds;
            counter.html(minute_text + ':' + second_text);
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
                            setOrderView('order-advised');
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
        };

        setInterval(function () {
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

        if (orderData && orderData.status === 'in transit') {
            renderMap(orderData);
        }

    }

    if ($('body.orders').length && typeof(substitutionOrderId) !== 'undefined') {

        setCountDown(orderChangeTimeOutSeconds);

        var substitutions = [];

        $("[name='order_item']").click(function (e) {
            e.preventDefault();
            var $link = $(this);
            var id = $link.data('id');
            $('#substitution-reason-' + id).toggle();
            if ($link.text() === 'Substitute') {
                substitutions.push(id);
                $link.text('Cancel');
            } else {
                $link.text('Substitute');
                var index = $.inArray(id, substitutions);
                if (index > -1) {
                    substitutions.splice(index, 1);
                }
            }
        });

        $('#substitutions-form').submit(function (e) {

            var substitutionsAndReasons = [];

            e.preventDefault();
            $(substitutions).each(function () {
                var reason = $('#substitution-reason-' + this);

                substitutionsAndReasons.push({
                    id: this,
                    reason: reason.val()
                });
            });

            $('#substitutions').val(JSON.stringify(substitutionsAndReasons))

            this.submit();
        });
    }

    if ($('body.orders').length && typeof(cancellationOrderId) !== 'undefined') {
        setCountDown(orderChangeTimeOutSeconds);
    }

};

$(document).on('page:load', ready);
$(document).ready(ready);