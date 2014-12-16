var ready = function () {
    if ($('.admin_orders').length) {
        $('#finished-packing').on('show.bs.modal', function (event) {
            var button = $(event.relatedTarget);
            var orderId = button.data('order-id');
            var postCode = button.data('customer-postcode');
            var modal = $(this);
            modal.find('#modal-order-id').text(orderId);
            modal.find('#modal-customer-postcode').text(postCode);
            $('#order-id').val(orderId);
        });
    }
};

$(document).on('page:load', ready);
$(document).ready(ready);

var checkOrdersStatus = function() {
    $.get('/admin/orders/refresh_all');
};

setInterval(function () {
    checkOrdersStatus();
    console.log(Date.now());
}, 10000);

checkOrdersStatus();