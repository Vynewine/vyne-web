$('document').ready(function() {
    if ($('body.delivery').length) {

        var map = L.map('map', {zoomControl: false}).setView([51.514525, -0.1050393], 13);

        map.addControl(L.control.zoom({position: 'topright'}));

        var gl = new L.Google('ROAD');
        map.addLayer(gl);


        var outside = [
            [0, -90],
            [0, 90],
            [90, -90],
            [90, 90]
        ];

        L.polygon([ outside , areas ]).addTo(map).setStyle(
            {
                color: '#009ee0',
                opacity: 0.8,
                weight: 2,
                fillColor: '#e8f8ff',
                fillOpacity: 0.45
            });
    }
});

