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

            if (data.actionable_order_counts.pending > 0) {
                $pending.css('display', 'inline');
                $pending.text(data.actionable_order_counts.pending);
            } else {
                $pending.css('display', 'none');
            }

            if (data.actionable_order_counts.packing > 0) {
                $packing.css('display', 'inline');
                $packing.text(data.actionable_order_counts.packing);
            } else {
                $packing.css('display', 'none');
            }

            if (data.actionable_order_counts.advised > 0) {
                $advised.css('display', 'inline');
                $advised.text(data.actionable_order_counts.advised);
            } else {
                $advised.css('display', 'none');
            }

            if (data.actionable_order_counts.in_transit > 0) {
                $inTransit.css('display', 'inline');
                $inTransit.text(data.actionable_order_counts.in_transit);
            } else {
                $inTransit.css('display', 'none');
            }

            if (data.actionable_order_counts.pickup > 0) {
                $pickup.css('display', 'inline');
                $pickup.text(data.actionable_order_counts.pickup);
            } else {
                $pickup.css('display', 'none');
            }

            if (data.actionable_order_counts.cancel_count > 0) {
                $cancelled.css('display', 'inline');
                $cancelled.text(data.actionable_order_counts.cancel_count);
            } else {
                $cancelled.css('display', 'none');
            }
        });
    }
};

$(document).on('page:load', ready);
$(document).ready(ready);
$(document).on("orderChange", function (event, type) {
    updateOrderBadgeCounts(type);
});


