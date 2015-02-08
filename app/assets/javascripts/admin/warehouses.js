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
        }

    }
};

$(document).ready(renderWarehouse);
$(document).on('page:load', renderWarehouse);