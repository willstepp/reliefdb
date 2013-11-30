$(function(){ 

  $('#ui-guide-action-button').click(function (e) {
    if (!$('#ui-location-coords').val()) {
      alert('Please choose a location');
      return false;
    }
  });

  $('#ui-why-here-buttons .button').click(function (e) {
    e.preventDefault();
    var b = $(e.target).attr('href');
    $('#ui-relief-type-input').val(b);
    $(e.target).addClass('button-selected');
    if (b == 'need') {
      $('#ui-give-help-button').removeClass('button-selected');
      $('#ui-guide-action-button').val('Find Relief');
      $('#ui-third-question').text('2) What kind of help do you need?');
      $('#ui-resources-label').text('...who needs the following resources:');
    } else {
      $('#ui-need-help-button').removeClass('button-selected');
      $('#ui-guide-action-button').val('Give Relief');
      $('#ui-third-question').text('2) What kind of help can you provide?');
      $('#ui-resources-label').text('...who can provide the following resources:');
    }
  });

  $('#ui-find-location-button').click(function (e) {
    e.preventDefault();
    if (navigator.geolocation) {
      $('#ui-find-location-button').attr('disabled', 'disabled');
      $('#ui-find-location-button').text('Finding your location...');
      navigator.geolocation.getCurrentPosition(navSuccess, error);
    } else {
      alert('your browser does not support geolocation');
    }
  });

  function navSuccess(position) {
    $('#ui-find-location-button').text('Use my current location');
    $('#ui-find-location-button').removeAttr('disabled');
    $('#ui-location-coords').val(position.coords.latitude + ';' + position.coords.longitude);
    $('#ui-location-results').text("You're at Latitude: " + position.coords.latitude + " and Longitude: " + position.coords.longitude);
    console.log(position);
    console.log(position.coords.latitude);
    console.log(position.coords.longitude);
  }

  function error(msg) {
    console.log(msg);
  }

  $('#ui-guide-map-button').click(function (e) {
    e.preventDefault();
    $('#ui-guide-results-container').hide();
    $('#ui-back-to-results').removeClass('hide');
    $('#map-canvas').show();
    initializeGuideMap();
  });

  $('#ui-back-to-results').click(function (e) {
    e.preventDefault();
    $('#map-canvas').hide();
    $('#ui-guide-results-container').show();
    $('#ui-back-to-results').addClass('hide');
  });
});