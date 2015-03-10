//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require library
//= require vendor/leaflet-0.7.3/leaflet.js
//= require vendor/leaflet-plugins-1.2.0/layer/tile/Google
//= require bootstrap-sprockets
//= require local_time
//= require bootstrap_growl/bootstrap-growl.min
//= require reconnecting-websocket/reconnecting-websocket
//= require admin/orders
//= require admin/notifications
//= require admin/warehouses

var advisor = advisor || null;

var addNestedField = function ($anchorNode, parentEntity, nestedEntity, fieldName) {
    var newId, newNm;
    var lastSum = parseInt($anchorNode.data('lastSum')) || 0;
    var fields = fieldName.split(",");
    for (var i = 0; i < fields.length; i++) {
        newId = parentEntity + '_' + nestedEntity + '_attributes_' + lastSum + '_' + fields[i];
        newNm = parentEntity + '[' + nestedEntity + '_attributes][' + lastSum + '][' + fields[i] + ']';
        $anchorNode.parent().append(
            $('<div>', {'class': 'form-group'}).append(
                $('<label>', {'for': newId}).html(fields[i].capitalise()),
                $('<br>'),
                $('<input>', {'id': newId, 'name': newNm, 'type': 'text', 'class': 'form-control'})
            )
        );
    }
    $anchorNode.data('lastSum', lastSum + 1);
};

var adminReady = function () {

    if (typeof(admin) !== 'undefined' && admin !== null && admin === true) {

        $('.add_nested_field').click(function (e) {
            e.preventDefault();
            addNestedField($(this), $(this).data('parentEntity'), $(this).data('nestedEntity'), $(this).data('fieldName'));
        });

        var $searchField = $('#search-wine');
        var token = $('meta[name="csrf-token"]').attr('content');

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

        $('#advisory-note-form').submit(function (e) {
            e.preventDefault();
            $('#advisory-note').val($('#advisory-note-text').val());
            $('#update-form').submit();
        });

        $('#edit-advisory-note-btn').click(function (e) {
            e.preventDefault();

            var existingNote = $('#existing-advisory-note').val();
            var $editNote = $('#edit-advisory-note-text');
            if (existingNote) {
                $editNote.val(existingNote);
            }

            $('#wine-id').val($('#existing-wine-id').val());
        });

        $('#edit-advisory-note-modal').on('shown.bs.modal', function () {
            var $note = $('#edit-advisory-note-text');
            $note.focus();
        });

        $('#edit-advisory-note-form').submit(function (e) {
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
            var basePriceWarehouse = wine.warehouse;

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

        $('#search-button').click(function(e) {
            e.preventDefault();
            $('#search-wine').blur();
            sortKeyWords();
        });

        var findKeywords = function (keywords) {
            var categories = [];
            $.each($('.tick-category'), function () {
                if (this.checked)
                    categories.push(parseInt(this.name.split('-')[2]));
            });
            var data = {
                'keywords': keywords,
                'single': $('#tick-sing').is(':checked'),
                'categories': categories,
                'order_id': $('#order-id').val(),
                'price_range_min' : $('#price-range-min').val(),
                'price_range_max' : $('#price-range-max').val()
            };
            postJSON('/admin/advise/results.json', token, data, renderItems, errorMethod);
        };

        if($('#price-range-min').length && $('#price-range-min').val() !== '' && $('#price-range-max').val() !== '') {
            findKeywords('');
        }

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

        $('.tick-category').change(function () {
            sortKeyWords();
        });

        $('#tick-sing').change(function () {
            sortKeyWords();
        });

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

$(document).ready(adminReady);
$(document).on('page:load', adminReady);
