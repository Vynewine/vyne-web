// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .


var formStepSetup = function() {
    var formSteps = $('.form-step')
    // console.log(formSteps);
    formSteps.each(function() {
        var buttonNext = $(this).find( "a.btn-next" );
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
    });
};

var ready = function() {
    // console.log('Doc is apparently ready');
    if (typeof(admin) !== 'undefined' && admin !== null && admin === true) {
        var tokenFields = ["occasion", "food", "note"];
        for (var i = 0; i < tokenFields.length; i++) {
            $("#wine_" + tokenFields[i] + "_tokens").tokenInput("/" + tokenFields[i] + "s.json", {
                crossDomain: false,
                prePopulate: $("#wine_" + tokenFields[i] + "_tokens").data("pre"),
                theme: 'facebook'
            });
        }
    } else {
        // console.log('Executing onReady functions');
        // Transferred from client.js
        loadCrappyCode();
        formStepSetup();
    }

};
// console.log(2);
$(document).ready(ready);
$(document).on('page:load', ready);