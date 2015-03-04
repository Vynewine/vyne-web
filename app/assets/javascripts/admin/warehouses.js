var renderWarehouse = function () {
    if ($('.warehouse-details').length) {

        var map = L.map('map', { scrollWheelZoom: false}).setView([warehouseLatitude, warehouseLongitude], 12);

        var gl = new L.Google('ROAD');
        map.addLayer(gl);

        if(deliveryArea.length > 0) {

            var outside = [
                [0, -90],
                [0, 90],
                [90, -90],
                [90, 90]
            ];

            L.polygon([outside, deliveryArea]).addTo(map).setStyle(
                {
                    color: '#009ee0',
                    opacity: 0.8,
                    weight: 2,
                    fillColor: '#e8f8ff',
                    fillOpacity: 0.45
                });

            map.fitBounds(deliveryArea);

            var warehouseIcon = L.icon({
                iconUrl: '/winebar.png',
                iconSize: [32, 32]
            });
            L.marker([warehouseLatitude, warehouseLongitude], {icon: warehouseIcon}).addTo(map);
        }

    }

    if($('body.admin_warehouses.edit').length || $('body.admin_warehouses.new').length) {

        var warehouseDeliveryPolygon;

        var drawMap = function(warehousePoints, lat, lng) {

            var myLatLng = new google.maps.LatLng(lat, lng);

            var mapOptions = {
                zoom: 12,
                center: myLatLng,
                mapTypeId: google.maps.MapTypeId.RoadMap,
                scrollwheel: false
            };

            var map = new google.maps.Map(document.getElementById('warehouse-delivery-map'), mapOptions);

            var points = [];

            warehousePoints.forEach(function(point) {
                points.push(new google.maps.LatLng(point[0], point[1]));
            });

            warehouseDeliveryPolygon = new google.maps.Polygon({
                paths: points,
                draggable: false,
                editable: true,
                strokeColor: '#FF0000',
                strokeOpacity: 0.8,
                strokeWeight: 2,
                fillColor: '#FF0000',
                fillOpacity: 0.35
            });

            warehouseDeliveryPolygon.setMap(map);

            new google.maps.Marker({
                position: myLatLng,
                map: map,
                title:"W"
            });

            //map.fitBounds(warehouseDeliveryPolygon);

            google.maps.event.addListener(warehouseDeliveryPolygon, "dragend", setNewPoints);
            google.maps.event.addListener(warehouseDeliveryPolygon.getPath(), "insert_at", setNewPoints);
            google.maps.event.addListener(warehouseDeliveryPolygon.getPath(), "remove_at", setNewPoints);
            google.maps.event.addListener(warehouseDeliveryPolygon.getPath(), "set_at", setNewPoints);

            setNewPoints();
        };

        var setNewPoints = function() {
            var len = warehouseDeliveryPolygon.getPath().getLength();
            var pointsToPostGis = '';

            for (var i = 0; i < len; i++) {
                pointsToPostGis += '[' + warehouseDeliveryPolygon.getPath().getAt(i).lng() + ', ' + warehouseDeliveryPolygon.getPath().getAt(i).lat() + ']';

                if(i < len - 1) {
                    pointsToPostGis += ',';
                }
            }

            $('#area').val('[[\n' + pointsToPostGis + '\n]]');
        };

        var generateGeoJSONCircle = function (c_lat, c_lng, radius, numSides) {

            var points = [];
            var earthRadius = 6371;
            var halfsides = numSides / 2;
            var pointsToPostGis = '';

            //angular distance covered on earth's surface
            var d = parseFloat(radius / 1000.) / earthRadius;

            var lat = (c_lat * Math.PI) / 180;
            var lon = (c_lng * Math.PI) / 180;



            for(var i = 0; i < numSides; i++) {
                var gpos = {};
                var bearing = i * Math.PI / halfsides; //rad
                gpos.latitude = Math.asin(Math.sin(lat) * Math.cos(d) + Math.cos(lat) * Math.sin(d) * Math.cos(bearing));
                gpos.longitude = ((lon + Math.atan2(Math.sin(bearing) * Math.sin(d) * Math.cos(lat), Math.cos(d) - Math.sin(lat) * Math.sin(gpos.latitude))) * 180) / Math.PI;
                gpos.latitude = (gpos.latitude * 180) / Math.PI;
                points.push([gpos.latitude, gpos.longitude]);
                pointsToPostGis += '[' + gpos.longitude + ', ' + gpos.latitude + '],\n';
            };

            return points;
        };

        if(typeof(deliveryArea) !== "undefined") {
            drawMap(deliveryArea, warehouseLat, warehouseLng);
            $('#warehouse-delivery-map').show();
        } else {
            $('#draw-new-delivery-map').click(function(e) {

                e.preventDefault();
                var lat = $('#warehouse_address_attributes_latitude').val();
                var lng = $('#warehouse_address_attributes_longitude').val();
                var points = generateGeoJSONCircle(lat, lng,
                    $('#delivery-radius-meters').val(),
                    $('#number-of-points').val()
                );

                drawMap(points, lat, lng);
                $('#warehouse-delivery-map').show();

            });
        }
    }
};

$(document).ready(renderWarehouse);
$(document).on('page:load', renderWarehouse);