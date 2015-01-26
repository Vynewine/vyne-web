//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require library
//= require jquery.typewatch
//= require vendor/leaflet-0.7.3/leaflet.js
//= require vendor/leaflet-plugins-1.2.0/layer/tile/Google
//= require bootstrap-sprockets
//= require local_time
//= require bootstrap_growl/bootstrap-growl.min
//= require admin_orders
//= require reconnecting-websocket/reconnecting-websocket
//= require admin_notifications

var advisor = advisor || null;

var addNestedField = function ($anchorNode, parentEntity, nestedEntity, fieldName) {
    var newId, newNm;
    var lastSum = parseInt($anchorNode.data('lastSum')) || 0;
    var fields = fieldName.split(",");
    for (var i = 0; i < fields.length; i++) {
        newId = parentEntity + '_' + nestedEntity + '_attributes_' + lastSum + '_' + fields[i];
        newNm = parentEntity + '[' + nestedEntity + '_attributes][' + lastSum + '][' + fields[i] + ']';
        $anchorNode.parent().append(
            $('<div>', {'class': 'field'}).append(
                $('<label>', {'for': newId}).html(fields[i].capitalise()),
                $('<br>'),
                $('<input>', {'id': newId, 'name': newNm, 'type': 'text'})
            )
        );
    }
    $anchorNode.data('lastSum', lastSum + 1);
};

var adminReady = function () {

    // // console.log('Doc is apparently ready');
    if (typeof(admin) !== 'undefined' && admin !== null && admin === true) {
        var tokenFields = ["occasion", "food", "note"];
        for (var i = 0; i < tokenFields.length; i++) {
            $("#wine_" + tokenFields[i] + "_tokens").tokenInput("/admin/" + tokenFields[i] + "s.json", {
                crossDomain: false,
                prePopulate: $("#wine_" + tokenFields[i] + "_tokens").data("pre"),
                theme: 'facebook'
            });
        }
        $('.add_nested_field').click(function (e) {
            e.preventDefault();
            // console.log('Generating field',
            //     $(this).data('parentEntity'),
            //     $(this).data('nestedEntity'),
            //     $(this).data('fieldName')
            // );
            // var $parentNode = $(this).parent();
            addNestedField($(this), $(this).data('parentEntity'), $(this).data('nestedEntity'), $(this).data('fieldName'));
            // $parentNode.css('background', 'red');
        });


        //**********************************************************************
        // Advisor area

        // Extra functionality for strings:
        String.prototype.trim = function () {
            return this.replace(/^\s+|\s+$/g, '');
        };
        String.prototype.ltrim = function () {
            return this.replace(/^\s+/, '');
        };
        String.prototype.rtrim = function () {
            return this.replace(/\s+$/, '');
        };
        String.prototype.fulltrim = function () {
            return this.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g, '').replace(/\s+/g, ' ');
        };

        // "Global" vars:
        var foods = {};
        var $searchField = $('#search-wine');
        token = $('meta[name="csrf-token"]').attr('content');

        //----------------------------------------------------------------------
        // Interface

        /**
         * Removes all data from fields and deletes order list.
         * Then reloads orders.
         */
        var reloadInterface = function () {
            // console.log('reloadInterface');
            // Empty fields:
            $('#warehouses-ids').val('');
            $('#order_id').val('');
            $('#wine_id').val('');
            $('#warehouse_id').val('');
            $('#quote_id').val('');
            // Hide stuff:
            $('#wine-list').hide();
            $('#wine-filters').hide();
            $('#confirmation-area').fadeOut();
            $('#orders-header').slideDown();
            $('#order-list').html('');
            postJSON('../orders/list.json', token, {'status': [1]}, renderOrders, errorMethod);
        };

        /**
         * Triggered when a wine and delivery are chosen and saved.
         * Reloads interface.
         */
        var wineChosen = function (d) {
            // console.log(d.message);
            if (d.message === 'success') {
                reloadInterface();
            } else {
                alert('Error: ' + d.message.split(':')[1]);
            }
        };

        /**
         * Confirm button's action.
         */
        var confirm = function (e) {
            e.preventDefault();
            var $a = $(event.target);
            if ($a.hasClass('disabled')) {
                // console.log('Not ready');
                return;
            }
            var order = $('#order_id').val();
            var wine = $('#wine_id').val();
            var warehouse = $('#warehouse_id').val();
            var quote = $('#quote_id').val();
            var data = {
                'wine': wine,
                'order': order,
                'warehouse': warehouse,
                'quote': quote
            };
            postJSON('complete.json', token, data, wineChosen, function () {
                alert('not okay');
            });
        };

        /**
         * Enables confirm button.
         */
        var enableConfirm = function () {
            $('#confirm').removeClass('disabled').addClass('green');
        };

        /**
         * Disables confirm button.
         */
        var disableConfirm = function () {
            $('#confirm').removeClass('green').addClass('disabled');
        };

        /**
         * Checks if all information is available for confirmation.
         */
        var parseOrderComplete = function () {
            var order = $('#order_id').val();
            var wine = $('#wine_id').val();
            var warehouse = $('#warehouse_id').val();
            var quote = $('#quote_id').val();
            if (order && wine && warehouse && quote) {
                enableConfirm();
            } else {
                disableConfirm();
            }
        };

        /**
         * Triggered when delivery quote is chosen.
         *
         */
        var chooseDelivery = function (e) {
            e.preventDefault();
            var $a = $(event.target);
            var $li = $a.parent();
            // var $ul = $li.parent();
            var quote = $li.data('id');
            // console.log($li);
            $('#quote_id').val(quote);
            $('#delivery_quotes>li').removeClass('disabled');
            $li.siblings().addClass('disabled');
            parseOrderComplete();
        };

        var showConfirmationWindow = function () {
            // // console.log('show!!');
            var order = $('#order_id').val();
            var wine = $('#wine_id').val();
            var warehouse = $('#warehouses-ids').val();
            var $orderTr = $("#order-" + order);
            var $wineTr = $("#wine-" + wine);
            disableConfirm();
            $('#delivery_quotes').hide();
            $('#delivery_quotes').html('');
            $('#loading').show();
            $('#confirm-name').html($orderTr.data('customer'));
            $('#confirm-address').html($orderTr.data('address'));
            $('#confirm-wine').html($wineTr.data('name'));
            $('#confirm-price').html("&pound;" + $wineTr.data('price') + ".00");
            $('#confirmation-area').fadeIn();

            var data = {
                'wine': wine,
                'order': order,
                'warehouse': warehouse
            };
            // console.log('chosen! ',data);
            postJSON('choose.json', token, data, function (r) {
                var details = '';
                var quote_id = '';
                for (var i = 0, quote; quote = r[i++];) {
                    details = quote.valid_until + ' - &pound;' + quote.price + ' - ' + quote.vehicle;
                    // 10/02/2014 - 10:32 - £6.45 - bicycle
                    quote_id = quote.id;
                    $('#delivery_quotes').append(
                        $('<li>')
                            .attr('id', 'quote_' + i)
                            .attr('data-id', quote_id)
                            .append(
                            $('<a>')
                                .attr('href', '#')
                                .html(details)
                                .click(chooseDelivery)
                        )
                    );

                }
                $('#loading').hide();
                $('#delivery_quotes').show();
            }, function (e) {
                // alert('not okay');
                console.error('not okay: ', e);
            });

        };

        $('#cancel-confirmation').click(function (e) {
            e.preventDefault();
            disableConfirm();
            $('#confirmation-area').fadeOut();
            $('#quote_id').val('');
            $('#warehouse_id').val('');
            $('#wine_id').val('');
        });

        $('#wine-additional-info').on('show.bs.modal', function (event) {

            var $tr = $(event.relatedTarget).closest('tr');
            var composition = $tr.data('composition');
            var singleEstate = $tr.data('single-estate');
            var inventoryId = $tr.data('inventory-id');

            var modal = $(this);
            modal.find('#modal-composition').text(composition);
            if (singleEstate) {
                modal.find('#modal-single-estate').text('Single Estate');
            } else {
                modal.find('#modal-single-estate').text('');
            }
            modal.find('#modal-inventory').attr('href', '/admin/inventories/' + inventoryId);
        });

        $('#wine-advisory-note-modal').on('show.bs.modal', function (event) {
            var $tr = $(event.relatedTarget).closest('tr');
            var wine = $tr.data('id');
            $('#wine-id').val(wine);

        }).on('shown.bs.modal', function () {
            var $note = $(this).find('#advisory-note-text');
            $note.focus();
        });

        $('#advisory-note-form').submit(function(e) {
            e.preventDefault();
            $('#advisory-note').val($('#advisory-note-text').val());
            $('#update-form').submit();
        });

        $('#edit-advisory-note-btn').click(function(e) {
            e.preventDefault();

            var existingNote = $('#existing-advisory-note').val();
            var $editNote = $('#edit-advisory-note-text');
            if(existingNote) {
                $editNote.val(existingNote);
            }

            $('#wine-id').val($('#existing-wine-id').val());
        });

        $('#edit-advisory-note-modal').on('shown.bs.modal', function () {
            var $note =  $('#edit-advisory-note-text');
            $note.focus();
        });

        $('#edit-advisory-note-form').submit(function(e) {
            e.preventDefault();
            $('#advisory-note').val($('#edit-advisory-note-text').val());
            $('#update-form').submit();
        });

        /**
         * Renders wine entry into interface
         */
        var renderWine = function (wine) {

            var $container = $('#wine-list>tbody');
            var basePrice = wine.price;
            var basePriceWarehouse = wine.warehouse; //redundant
            var basePriceQuantity = wine.quantity;


            var warehouseOpen = true;
            var cost = wine.cost;

            if (basePrice === 0) return;

            var compositionArray = [];
            for (var i = 0, composition; composition = wine.compositions[i++];) {
                compositionArray.push(composition.name + (composition.percentage ? ': ' + composition.percentage + '%' : ''));
            }

            var region = [];

            if (wine.appellation) {
                region.push('(' + wine.appellation + ')');
            }

            if (wine.region) {
                region.push(wine.region);
            }

            if (wine.subregion) {
                region.push(wine.subregion);
            }

            if (wine.locale) {
                region.push(wine.locale);
            }

            $container.append(
                $('<tr>')
                    .attr('id', "wine-" + wine.id)
                    .attr('data-id', wine.id)
                    .attr('data-name', wine.name + ' ' + wine.vintage)
                    .attr('data-price', basePrice)
                    .attr('data-warehouse', basePriceWarehouse)
                    .attr('data-single-estate', wine.single_estate)
                    .attr('data-composition', compositionArray.join(', '))
                    .attr('data-inventory-id', wine.inventory_id)
                    .addClass(warehouseOpen ? 'warehouse-open' : 'warehouse-closed')
                    .addClass('wine')
                    .append(
                    $('<td>').append(
                        $('<button>').addClass('btn btn-default')
                            .attr('data-toggle', 'modal')
                            .attr('data-target', '#wine-advisory-note-modal')
                            .append(
                            $('<span>').addClass('glyphicon glyphicon-plus')
                        )//.click(chooseWine)
                    ),
                    $('<td>').addClass('flag').append(
                        $('<img>')
                            .attr('alt', wine.countryName)
                            .attr('src', wine.countryFlag)
                    ),
                    $('<td>').html(wine.vendor_sku),
                    $('<td>').addClass('name').html(
                        wine.name +
                        ' - ' + wine.vintage + ' - ' + wine.producer + (wine.bottle_size ? ' - ' + wine.bottle_size + 'CL' : '')
                    ),
                    $('<td>').addClass('type').html(
                        wine.type + ' / ' + region.join(', ')
                    ),
                    $('<td>').addClass('cost').html(
                        '&pound;' + cost
                    ),
                    $('<td>').html(
                        wine.quantity
                    ),
                    $('<td>').append(
                        $('<button>').addClass('btn btn-default')
                            .attr('data-toggle', 'modal')
                            .attr('data-target', '#wine-additional-info')
                            .append(
                            $('<span>').addClass('glyphicon glyphicon-info-sign')
                        )
                    )
                )
            );
        };

        var renderItems = function (r) {
            var $container = $('#wine-list');
            $container.html('');
            $container.append(
                $('<thead>').append(
                    $('<tr>').append(
                        $('<th>').html(''),
                        $('<th>').html(''),
                        $('<th>').html('SKU'),
                        $('<th>').html('Name'),
                        $('<th>').html('Type / Region'),
                        $('<th>').html('Cost'),
                        $('<th>').html('Qty'),
                        $('<th>').html('Info')
                    )
                ),
                $('<tbody>')
            );
            for (var i = 0, wine; wine = r[i++];) {
                renderWine(wine);
            }
            $container.slideDown(200);
        };

        var errorMethod = function (e) {
            // console.log('not okay');
        };

        var findKeywords = function (keywords) {
            var categories = [];
            $.each($('.tick-category'), function () {
                if (this.checked)
                    categories.push(parseInt(this.name.split('-')[2]));
            });
            var data = {
                'keywords': keywords,
                'warehouses': $('#warehouses-ids').val(),
                'single': $('#tick-sing').is(':checked'),
                'categories': categories,
                'order_id': $('#order-id').val()
            };
            // console.log('data', data);
            postJSON('/admin/advise/results.json', token, data, renderItems, errorMethod);
        };

        var sortKeyWords = function (e) {
            $('#wine-list').slideUp(100);
            var keywordLongEnough = false;
            var keywords = $searchField.val().split(',');
            for (var i = keywords.length - 1; i >= 0; i--) {
                keywords[i] = keywords[i].trim();
                if (keywords[i].length > 1) {
                    keywordLongEnough = true;
                }
            }
            if (keywordLongEnough) {
                findKeywords(keywords.join(' '));
            }
        };


        /**
         * Copies the information from the order data into the search field
         */
        var copyInfo = function (e) {
            e.preventDefault();
            var val = $searchField.val();
            var newVal = $('#order-info-value').text();
            val = val.length > 0 ? val + ' ' : '';
            val += newVal;
            $searchField.focus();
            $searchField.val(val);
            sortKeyWords();
        };

        /**
         * Advise action.
         */
        var adviseActions = function ($this, $orderRecoverAnchor) {
            // console.log('advise');
            // debugger;
            var $td = $this.closest("td");
            var $tr = $td.closest("tr");
            var $table = $tr.closest("table");
            var $siblings = $tr.siblings();
            var warehouses = $tr.data('warehouses');
            var id = $tr.data('id');
            var info = $tr.data('info');
            $siblings.removeClass('selected');
            $siblings.hide();
            $('#orders-header').hide();
            $tr.addClass('selected');
            $td.html('');
            $td.append(
                $orderRecoverAnchor.unbind().click(function (e) {
                    e.preventDefault();
                    recoverActions($orderRecoverAnchor, $this);
                })
            );
            // Show search field
            $('#wine-filters').slideDown();
            $('#wine-list').html('').show();
            $searchField.focus();
            $('#order_id').val(id);
            console.log(warehouses);
            $('#warehouses-ids').val(warehouses);

            var suggestedFood = [];
            if (typeof(info) !== 'undefined' && info !== null) {
                if (typeof(info.foods) !== 'undefined' && info.foods !== null) {
                    for (var i = 0, orderFood; orderFood = info.foods[i++];) {
                        for (var j = 0, food; food = foods[j++];) {
                            if (orderFood === food.id) {
                                suggestedFood.push(food.name);
                            }
                        }
                    }
                    $table.after(
                        $('<div>')
                            .attr('id', 'order-info')
                            .append(
                            $('<span>')
                                .attr('id', 'order-info-value')
                                .text(suggestedFood.join(' ')),
                            $('<a>')
                                .attr('href', '#')
                                .text('copy')
                                .css('float', 'right')
                                .click(copyInfo)
                        )
                    );
                }
            }


        };

        /**
         * Return action
         */
        var recoverActions = function ($this, $adviseAnchor) {
            var $td = $this.closest("td");
            var $tr = $td.closest("tr");
            var $siblings = $tr.siblings();
            $('#order_id').val('');
            $('#warehouses-ids').val('');
            $('#quote_id').val('');
            $('#warehouse_id').val('');
            $tr.removeClass('selected');
            $td.html('');
            $('#order-info').remove();
            $td.append(
                $adviseAnchor.unbind().click(function (e) {
                    e.preventDefault();
                    adviseActions($adviseAnchor, $this);
                })
            );
            $('#wine-list').hide();
            $('#wine-filters').hide();
            $('#orders-header').slideDown();
            $siblings.slideDown();
        };

        /**
         * Search field:
         */
        $searchField.typeWatch({
            highlight: true,
            wait: 800,
            captureLength: -1,
            callback: sortKeyWords
        });

        $('.tick-category').change(function () {
            sortKeyWords();
        });

        $('#tick-sing').change(function () {
            sortKeyWords();
        });

        $('#confirm').click(confirm);

        var refreshDelivery = $('#refresh-delivery');

        refreshDelivery.click(function () {
            var orderId = refreshDelivery.data('id');

            $.ajax({
                type: "PUT",
                beforeSend: function (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', token)
                },
                url: '/admin/delivery/' + orderId,
                success: function (data) {
                    location.reload();
                },
                error: function (err) {
                    console.log(err);
                    alert(err.responseJSON.errors)
                }
            });

        })

    }
};

var renderWarehouse = function () {
    if ($('body.admin_warehouses').length) {

        var map = L.map('map').setView([warehouseLatitude, warehouseLongitude], 12);

        var gl = new L.Google('ROAD');
        map.addLayer(gl);

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
};

$(document).ready(adminReady);
$(document).on('page:load', adminReady);

$(document).ready(renderWarehouse);
$(document).on('page:load', renderWarehouse);
