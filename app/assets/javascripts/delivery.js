var deliveryJsrRady = function () {
    if (($('body.delivery').length || $('div.delivery').length) && areas.length > 0) {

        var map = L.map('map', {zoomControl: false, scrollWheelZoom: false});
        map.addControl(L.control.zoom({position: 'topright'}));

        if (isMobile.any()) {
            map.dragging.disable();
            map.tap.disable()
        }

        var gl = new L.Google('ROAD');
        map.addLayer(gl);

        var outside = [
            [0, -90],
            [0, 90],
            [90, -90],
            [90, 90]
        ];

        var allAreas = [];
        var deliveryAreas = [];
        allAreas.push(outside);

        areas.forEach(function(area) {
            allAreas.push(area);
            deliveryAreas.push(area);
        });

        L.polygon(allAreas).addTo(map).setStyle(
            {
                color: '#009ee0',
                opacity: 0.8,
                weight: 2,
                fillColor: '#e8f8ff',
                fillOpacity: 0.45
            });

        map.fitBounds(deliveryAreas);

    }
};

$(document).on('page:load', deliveryJsrRady);
$(document).ready(deliveryJsrRady);
