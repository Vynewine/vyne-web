// Fades in and out the different register steps
var formStepSetup = function() {
    var formSteps = $('.form-step')
    // console.log(formSteps);
    formSteps.each(function() {
        var buttonNext = $(this).find( "a.btn-next" );
        var buttonDone = $(this).find( "input[type=submit]" );
        console.log(buttonDone);
        buttonNext.click(function(e){
            e.preventDefault();
            var parentStep = $(this).parents('.form-step');
            var nextStepName = $(this).data('nextStep');
            var nextStep = $("."+nextStepName);
            // console.log(parentStep);
            // console.log(nextStep);
            parentStep.fadeOut(function(){
                nextStep.fadeIn();
            });
        });
        buttonDone.click(function(e){
            e.preventDefault();
            var postcode = $('#clientPostCode').val();
            console.log('postcode is ' + postcode);
            var mapUtil = new MapUtility();
            var coordinates = mapUtil.locateAndDo(postcode, function(data) {
                var distance = mapUtil.calculateDistancesFor(data.results[0].geometry.location.lng, data.results[0].geometry.location.lat);
                console.log('distance is ' + distance + ' km');
                console.log('distance is ' + mapUtil.kmToMile(distance) + ' miles');
            });
        });
    });
};