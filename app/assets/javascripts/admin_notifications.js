var scheme = window.document.location.protocol === "http:" ? "ws://" : "wss://";
var uri = scheme + window.document.location.host + "/";
var ws = new WebSocket(uri);

var setupNotifications = function () {

    ws.onmessage = function (message) {
        var data = JSON.parse(message.data);
        $.growl({
            message: 'Warehouse: ' + data.warehouses + ', Text:' + data.text + ' '
        },{
            type: 'info'
        });
    };

};

$(document).ready(setupNotifications);
