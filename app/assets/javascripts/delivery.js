var ready = function () {
    if (($('body.delivery').length || $('div.delivery').length) && areas.length > 0) {

        var map = L.map('map', {zoomControl: false, scrollWheelZoom: false}).setView([51.514525, -0.1050393], 12);

        map.addControl(L.control.zoom({position: 'topright'}));

        var gl = new L.Google('ROAD');
        map.addLayer(gl);

        if($('body.mobile-device').length) {
            map.dragging.disable();
            map.tap.disable()
        }

        var outside = [
            [0, -90],
            [0, 90],
            [90, -90],
            [90, 90]
        ];

        L.polygon([outside, areas]).addTo(map).setStyle(
            {
                color: '#009ee0',
                opacity: 0.8,
                weight: 2,
                fillColor: '#e8f8ff',
                fillOpacity: 0.45
            });
    }
};

$(document).on('page:load', ready);
$(document).ready(ready);
