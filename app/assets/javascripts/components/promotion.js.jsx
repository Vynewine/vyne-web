PromotionHeader = React.createClass({
    render: function () {

        if (!this.props.promotion) {
            return false;
        }

        var promotion_section = '';

        var setPromotion = function (message, shouldSignUp) {

            var signUpLink = '';

            if (shouldSignUp) {
                signUpLink = (
                    <div className="col-xs-12">
                        <a href="/users/sign_up" className="btn btn-primary btn-sm">Register your promotion
                            here</a>
                    </div>
                )
            }

            promotion_section = (
                <div className="col-xs-12 promotion-message">
                    <i className="fa fa-gift"></i> {message}
                    {signUpLink}
                </div>
            )
        };


        if (this.props.promotion.code && typeof(this.props.weDeliver) !== 'undefined') {

            var promotion = this.props.promotion;

            if (!this.props.weDeliver) {
                setPromotion('We currently don\'t deliver to your area. Register now and we\'ll save' +
                ' your promotion in your account.', true);

            } else {
                setPromotion('Your promotion (code ' + promotion.code +
                ' - "' + promotion.title + '") will be applied to your order automatically upon checkout.', false);
            }
        } else {
            return false;
        }


        return (
            <div className="row">
                {promotion_section}
            </div>
        )
    }
});

var PromotionHeaderContainer = Marty.createContainer(PromotionHeader, {
    listenTo: [PromotionStore],
    fetch: {
        promotion: function(){
            return PromotionStore.getPromotion();
        }
    },
    pending: function() {
        return <div className='loading'>Loading Promotion...</div>;
    },
    failed: function(errors) {
        console.log(errors)
        return <div className='error'>Failed to load promotion. {errors}</div>;
    }
});