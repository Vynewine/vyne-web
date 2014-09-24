//= require jquery
//= require library
//= require jquery.typewatch

var addNestedField = function($anchorNode, parentEntity, nestedEntity, fieldName) {
    // $parentNode
    // parentEntity
    // nestedEntity
    // fieldName
    // id="wine_compositions_attributes_1_grape"
    // name="wine[compositions_attributes][1][grape]"

    // .before() – Inserts content outside and before.
    // .prepend() - Inserts content inside and before.
    // .after() – Inserts content outside and after.
    // .append() – Inserts content inside and after.
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






        String.prototype.trim    = function(){return this.replace(/^\s+|\s+$/g, '');};
        String.prototype.ltrim   = function(){return this.replace(/^\s+/,'');};
        String.prototype.rtrim   = function(){return this.replace(/\s+$/,'');};
        String.prototype.fulltrim= function(){return this.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,'').replace(/\s+/g,' ');};

        token = $('meta[name="csrf-token"]').attr('content');


        var renderWine = function(wine) {
            console.log('rendering wine', wine);
            var $container = $('#wine-list>table>tbody');
            var types = [];
            for (var i = 0, type; type = wine.type[i++];) {
                types.push(type.name);
            }
            $container.append(
                $('<tr>').addClass('wine').append(
                    // $('<td>').addClass('flag').html(wine.name),
                    $('<td>').addClass('name').html(wine.name),
                    $('<td>').addClass('vintage').html(wine.vintage),
                    $('<td>').addClass('type').html(types.join(', '))
                )
            );
        };

        var renderItems = function(r) {
            var $container = $('#wine-list');
            $container.html('');
            $container.append(
                $('<table>').append(
                    $('<tbody>')
                )
            );
            for (var i = 0, wine; wine = r[i++];) {
                renderWine(wine);
            }            
        };

        var parseResults = function(r){
            console.log('okay');
            console.log(r);
            renderItems(r);
        };
        var errorMethod = function(e){
            console.log('not okay');
        };

        var findKeywords = function(keywords){
            // var token = $('meta[name="csrf-token"]').attr('content');
            var data = {
                'keywords':keywords
            };
            console.log('data', data);
            postJSON('advise/results.json', token, data, parseResults, errorMethod);
        };

        var sortKeyWords = function(e){
            console.log('trigger');
            $this = $(this);
            var keywords = $this.val().split(',');
            for (var i = keywords.length - 1; i >= 0; i--) {
                keywords[i] = keywords[i].trim();
            }
            // console.log('keywords: ', keywords);
            findKeywords(keywords.join(' '));
        };

        $('.advisor-area>.wine-filters>#search').typeWatch({
                highlight: true,
                     wait: 800,
            captureLength: -1,
                 callback: sortKeyWords
        });

        







// http://127.0.0.1:3000/admin/advise/results.json

    }
};
// console.log(2);
$(document).ready(adminReady);
$(document).on('page:load', adminReady);
