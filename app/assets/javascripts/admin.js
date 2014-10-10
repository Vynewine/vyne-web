//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require library
//= require jquery.typewatch

var advisor = advisor || null;

var addNestedField = function($anchorNode, parentEntity, nestedEntity, fieldName) {
    var newId, newNm;
    var lastSum = parseInt($anchorNode.data('lastSum')) || 0;
    var fields = fieldName.split(",");
    for (var i = 0; i < fields.length; i++) {
        newId = parentEntity + '_' + nestedEntity + '_attributes_' + lastSum + '_' + fields[i];
        newNm = parentEntity + '[' + nestedEntity + '_attributes][' + lastSum + '][' + fields[i] + ']';
        $anchorNode.parent().append(
            $('<div>', { 'class':'field' }).append(
                $('<label>', { 'for': newId }).html(fields[i].capitalise()),
                $('<br>'),
                $('<input>', { 'id': newId, 'name': newNm, 'type': 'text' })
            )
        );
    }
    $anchorNode.data('lastSum', lastSum+1);
};

var adminReady = function() {
    console.log('ADMIN JS');
    // console.log('Doc is apparently ready');
    if (typeof(admin) !== 'undefined' && admin !== null && admin === true) {
        var tokenFields = ["occasion", "food", "note"];
        for (var i = 0; i < tokenFields.length; i++) {
            $("#wine_" + tokenFields[i] + "_tokens").tokenInput("/admin/" + tokenFields[i] + "s.json", {
                crossDomain: false,
                prePopulate: $("#wine_" + tokenFields[i] + "_tokens").data("pre"),
                theme: 'facebook'
            });
        }
        $('.add_nested_field').click(function(e){
            e.preventDefault();
            console.log('Generating field',
                $(this).data('parentEntity'),
                $(this).data('nestedEntity'),
                $(this).data('fieldName')
            );
            // var $parentNode = $(this).parent();
            addNestedField($(this), $(this).data('parentEntity'), $(this).data('nestedEntity'), $(this).data('fieldName'));
            // $parentNode.css('background', 'red');
        });



        //****************************
        // Advisor area


        var foods = {};
        var $searchField = $('.advisor-area>#wine-filters>#search');


        String.prototype.trim    = function(){return this.replace(/^\s+|\s+$/g, '');};
        String.prototype.ltrim   = function(){return this.replace(/^\s+/,'');};
        String.prototype.rtrim   = function(){return this.replace(/\s+$/,'');};
        String.prototype.fulltrim= function(){return this.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,'').replace(/\s+/g,' ');};

        token = $('meta[name="csrf-token"]').attr('content');

        var reloadInterface = function() {
            console.log('reloadInterface');

                $('#order_id').val('');
                $('#warehouses_ids').val('');

                $('#wine-list').hide();
                $('#wine-filters').hide();
                $('#orders-header').slideDown();
            $('#order-list').html('');

            postJSON('../orders/list.json', token, {'status':[2]}, parseOrders, errorMethod);
        };

        var wineChosen = function(d) {
            console.log(d.message);
            if (d.message==='success') {
                reloadInterface();
            } else {
                alert('Error: ' + d.message.split(':')[1]);
            }
        };

        var chooseWine = function(e) {
            e.preventDefault();

            var result = confirm("Are you sure?");
            if (result === false) {
                return;
            }
            var $tr = $(this).closest('tr');
            var wine = parseInt($tr.data('id'));
            var order = parseInt($('#order_id').val());
            var warehouse = parseInt($tr.data('warehouse'));
            var data = {
                'wine':wine,
                'order':order,
                'warehouse':warehouse
            };
            console.log('chosen! ',data);
            postJSON('choose.json', token, data, wineChosen, function() {
                alert('not okay');
            });

        };

        var renderWine = function(wine) {
            console.log('rendering wine', wine);
            var $container = $('#wine-list>table>tbody');
            // var types = [];
            // for (var i = 0, type; type = wine.type[i++];) {
            //     types.push(type.name);
            // }

            var basePrice = 0;
            var basePriceWarehouse = 0;
            var basePriceQuantity = 0;
            var multiplePrices = wine.availability.length > 1 ? '+' : ''
            for (var i = 0, availability; availability = wine.availability[i++];) {
                if (availability.quantity > 0) {
                    if (availability.price < basePrice || basePrice === 0) {
                        basePrice = availability.price;
                        basePriceQuantity = availability.quantity;
                        basePriceWarehouse = availability.warehouse;
                    }
                }
            }

            if (basePrice === 0) return;

            var compositionArray = [];
            for (var i = 0, composition; composition = wine.compositions[i++];) {
                compositionArray.push(composition.name + ': ' + composition.quantity + '%');
            }

            var $se, $vg, $vn, $og;

            if (wine.single_estate)
                $se = $('<span>').addClass('single flaticon solid house-2');
            if (wine.vegan)
                $vn = $('<span>').addClass('vegan').html('Vn');
            if (wine.organic)
                $og = $('<span>').addClass('organic').html('Og');


            $container.append(
                $('<tr>')
                .attr('data-id', wine.id)
                .attr('data-warehouse', basePriceWarehouse)
                .addClass('wine').append(
                    $('<td>').addClass('flag').append(
                        $('<img>')
                            .attr('alt', wine.countryName)
                            .attr('src', "/assets/flags/"+wine.countryCode+".png")
                    ),
                    $('<td>').addClass('subregion').html(wine.subregion),
                    $('<td>').addClass('name').html(
                        wine.name + (wine.appellation ? " ("+wine.appellation+")" : '') +
                        ' ' + wine.vintage
                    ),
                    $('<td>').addClass('type').html(
                        wine.types.join(', ')
                    ),
                    $('<td>').addClass('price').html(
                        '&pound;' + basePrice + multiplePrices
                    ),
                    $('<td>').addClass('composition').html(
                        compositionArray.join(', ')
                    ),
                    $('<td>').addClass('flags').append(
                        $se, $vg, $vn, $og
                    ),
                    $('<td>').addClass('actions').append(
                        $('<a>').attr('href', '#').html('Choose').click(chooseWine)
                    )
                )
            );
        };

        var renderItems = function(r) {
            var $container = $('#wine-list');
            $container.html('');
            $container.append(
                $('<table>').attr('border','1').append(
                    $('<tbody>')
                )
            );
            for (var i = 0, wine; wine = r[i++];) {
                renderWine(wine);
            }
            $container.slideDown(200);                        
        };

        var parseResults = function(r){
            // console.log('okay');
            // console.log(r);
            renderItems(r);
        };
        var errorMethod = function(e){
            console.log('not okay');
        };

        var findKeywords = function(keywords){
            var categories = [];
            $.each($('.tick-category'), function() {
                if (this.checked)
                    categories.push(parseInt(this.name.split('-')[2]));
            });
            var data = {
                  'keywords': keywords,
                'warehouses': $('#warehouses_ids').val(),
                    'single': $('#tick-sing').is(':checked'),
                     'vegan': $('#tick-vegn').is(':checked'),
                   'organic': $('#tick-orgc').is(':checked'),
                'categories': categories
            };
            console.log('data', data);
            postJSON('results.json', token, data, parseResults, errorMethod);
        };

        var sortKeyWords = function(e){
            $('#wine-list').slideUp(100);
            var keywords = $searchField.val().split(',');
            for (var i = keywords.length - 1; i >= 0; i--) {
                keywords[i] = keywords[i].trim();
            }
            findKeywords(keywords.join(' '));
        };



        /**
         * Copies the information from the order data into the search field
         */
        var copyInfo = function(e) {
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
        var adviseActions = function($this, $orderRecoverAnchor) {
            console.log('advise');
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
                $orderRecoverAnchor.unbind().click(function(e){
                    e.preventDefault();
                    recoverActions($orderRecoverAnchor, $this);
                })
            );
            // Show search field
            $('#wine-filters').slideDown();
            $('#wine-list').html('').show();
            $searchField.focus();
            $('#order_id').val(id);
            $('#warehouses_ids').val(warehouses);

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
        var recoverActions = function($this, $adviseAnchor) {
            var $td = $this.closest("td");
            var $tr = $td.closest("tr");
            var $siblings = $tr.siblings();
            $('#order_id').val('');
            $('#warehouses_ids').val('');
            $tr.removeClass('selected');
            $td.html('');
            $('#order-info').remove();
            $td.append(
                $adviseAnchor.unbind().click(function(e){
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
         * Draws single orders
         */
        var renderOrder = function(order) {
            var $container = $('#order-list>table>tbody');
            var $adviseAnchor = $('<a>').attr('href', '#').text('Advise');
            var $orderRecoverAnchor = $('<a>').attr('href', '#').text('Return');
            var info = JSON.parse(order.info);
            var warehousesIds = [];

            if (info == null)
                info = {};

            if (info.warehouses !== undefined) {
                for (var i = 0, warehouse; warehouse = info.warehouses[i++];) {
                    warehousesIds.push(warehouse.id);
                }
            }

            $adviseAnchor.click(function(e){
                e.preventDefault();
                adviseActions($(this), $orderRecoverAnchor);
            });

            $orderRecoverAnchor.click(function(e){
                e.preventDefault();
                recoverActions($(this), $adviseAnchor);
            });

            $container.append(
                $('<tr>')
                  .addClass('order')
                  .attr("data-warehouses", info.warehouses.join(','))
                  .attr("data-id", order.id)
                  .attr("data-info", order.info)
                  .append(
                      $('<td>').addClass('client').html(
                          order.client.first_name + ' ' + order.client.last_name
                      ),
                      $('<td>').addClass('postcode').html(
                          order.address.postcode
                      ),
                      $('<td>').addClass('actions').append($adviseAnchor)
                )
            );
        };

        /**
         * Creates table of orders and draws all items
         */
        var renderOrders = function(r) {
            var $container = $('#order-list');
            $container.append(
                $('<table>').attr('border','1').append(
                    $('<tbody>')
                )
            );
            for (var i = 0, order; order = r[i++];) {
                renderOrder(order);
            } 
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

        /**
         * Load data
         */
        if (advisor) {
            loadJSON('../foods.json', function(d) {
                foods = d;
                postJSON('../orders/list.json', token, {'status':[2]}, renderOrders, errorMethod);
            }, errorMethod);
        }

        /**
         * Reload data
         */
        $('#reload-orders').click(function(e){
            e.preventDefault();
            $('#order-list').html('');
            postJSON('../orders/list.json', token, {'status':[2]}, renderOrders, errorMethod);
        });

    }
};



// console.log(2);
$(document).ready(adminReady);
$(document).on('page:load', adminReady);
