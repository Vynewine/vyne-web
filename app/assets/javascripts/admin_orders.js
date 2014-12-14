var ready = function () {
    if ($('.admin_orders').length) {
        $('#finished-packing').on('show.bs.modal', function (event) {
            var button = $(event.relatedTarget);
            var orderId = button.data('order-id');
            var postCode = button.data('customer-postcode');
            // If necessary, you could initiate an AJAX request here (and then do the updating in a callback).
            // Update the modal's content. We'll use jQuery here, but you could use a data binding library or other methods instead.
            var modal = $(this);
            modal.find('#modal-order-id').text(orderId);
            modal.find('#modal-customer-postcode').text(postCode);
            $('#order-id').val(orderId);
        });
    }
};

$(document).on('page:load', ready);
$(document).ready(ready);