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

var updateOrderBadgeCounts = function (type) {
    if ($('.admin_orders').length) {

        $.get('/admin/orders/order_counts', function (data) {
            var $pending = $('#badge-pending');
            var $packing = $('#badge-packing');
            var $advised = $('#badge-advised');
            var $inTransit = $('#badge-in-transit');
            var $pickup = $('#badge-pickup');
            var $cancelled = $('#badge-cancelled');
            var $paymentFailed = $('#badge-payment-failed');

            updateBadge(data.actionable_order_counts.pending, $pending);
            updateBadge(data.actionable_order_counts.packing, $packing);
            updateBadge(data.actionable_order_counts.advised, $advised);
            updateBadge(data.actionable_order_counts.in_transit, $inTransit);
            updateBadge(data.actionable_order_counts.pickup, $pickup);
            updateBadge(data.actionable_order_counts.cancel_count, $cancelled);
            updateBadge(data.actionable_order_counts.payment_failed, $paymentFailed);
        });
    }
};

var updateBadge = function(count, control) {
    if (count > 0) {
        control.css('display', 'inline');
        control.text(count);
    } else {
        control.css('display', 'none');
    }
};

$(document).on('page:load', ready);
$(document).ready(ready);
$(document).on("orderChange", function (event, type) {
    updateOrderBadgeCounts(type);
});


