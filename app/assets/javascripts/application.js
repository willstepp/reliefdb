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
//= require foundation
//= require_tree .

$(function(){ 
  $(document).foundation();

  //disable fastclick on Google Places functionality, because it breaks touch input
  $(document).on({
    'DOMNodeInserted': function() {
      $('.pac-item, .pac-item span', this).addClass('needsclick');
    }
  }, '.pac-container');

});

$('.noEnterFormSubmit').keypress(function(e){
    if ( e.which == 13 ) e.preventDefault();
});