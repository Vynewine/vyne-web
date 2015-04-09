NavMiniCart = React.createClass({
    getInitialState: function () {

        return {

        }
    },
    render: function () {

        var cartCount = 0;
        var link = '/';

        if(typeof($.cookie('wines')) !== 'undefined') {

            var wines = JSON.parse($.cookie('wines'));

            if (wines.length > 0) {
                cartCount = wines.length;

                $.cookie.raw = true;

                if(typeof($.cookie('postcode')) !== 'undefined') {
                    link += 'shop/neworder?postcode=' + $.cookie('postcode');
                } else {
                    return false;
                }

                if(typeof($.cookie('warehouse_id')) !== 'undefined') {
                    link += '&warehouse_id=' + $.cookie('warehouse_id');
                } else {
                    return false;
                }

                if(typeof($.cookie('slot_date')) !== 'undefined') {
                    link += '&slot_date=' + $.cookie('slot_date');
                }

                if(typeof($.cookie('slot_from')) !== 'undefined') {
                    link += '&slot_from=' + $.cookie('slot_from');
                }

                if(typeof($.cookie('slot_to')) !== 'undefined') {
                    link += '&slot_to=' + $.cookie('slot_to');
                }

                $.cookie.raw = false;

            } else {
                return false;
            }

        } else {
            return false;
        }

        return (
            <a className="cart-link" href={link} data-no-turbolink="true">
                <div className="mini-cart-image">
                    <span className="cart-count">{cartCount}</span>
                </div>
            </a>
        )
    }
});

var renderNavMiniCart = function () {

    if($('#mini-cart-uncollapsed').length) {
        React.render(
            <NavMiniCart />,
            document.getElementById('mini-cart-uncollapsed')
        );

        React.render(
            <NavMiniCart />,
            document.getElementById('mini-cart')
        );
    }
};

$(document).ready(renderNavMiniCart);
$(document).on('page:load', renderNavMiniCart);