/**
 * This file provides a way to register Vyne POS app running on Android Device
 */

var confirmRegistration;

$('document').ready(function () {
    if ($('#device-registration').length) {

        var $message = $('#message');

        var initiateDeviceRegistration = function () {
            //AndroidFunction is function injected by Android Device
            if (typeof(AndroidFunction) !== 'undefined') {
                AndroidFunction.registerDevice();
            } else {
                $message.text('Android interface not found');
            }
        };

        initiateDeviceRegistration();

        //Called from Vyne POS Android app upon completing registration.
        //Call authenticated on the server.
        confirmRegistration = function (device_key, registrationId) {

            var $error = $('#device-registration-errors');

            $.ajax({
                type: "POST",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').last().attr('content'))
                },
                url: '/admin/devices/register',
                data: {
                    key: device_key,
                    registration_id: registrationId

                },
                error: function (data) {

                    if (data && data.responseJSON) {
                        var errors = data.responseJSON.errors;
                        if (errors) {
                            error = errors.join(', ');
                            $error.text(error);
                        }
                    } else {

                        if (data.statusText) {
                            $error.text(data.statusText);
                        } else {
                            $error.text('Error');
                        }
                    }
                    $error.show();
                },
                success: function () {
                    location.reload();
                }
            });
        };
    }
});