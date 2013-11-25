$(function(){ 

  $('#ui-why-here-buttons .button').click(function (e) {
    e.preventDefault();
    var b = $(e.target).attr('href');
    $(e.target).addClass('button-selected');
    if (b == 'need') {
      $('#ui-give-help-button').removeClass('button-selected');
      $('#ui-guide-action-button').text('Find Relief');
      $('#ui-third-question').text('3) What kind of help do you need?');
      $('#ui-resources-label').text('...who needs the following resources:');
    } else {
      $('#ui-need-help-button').removeClass('button-selected');
      $('#ui-guide-action-button').text('Give Relief');
      $('#ui-third-question').text('3) What kind of help can you provide?');
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

  $('#ui-guide-action-button').click(function (e) {
    e.preventDefault();
    alert('Coming Soon!');
  })

  function navSuccess(position) {
    $('#ui-find-location-button').text('Use my current location');
    $('#ui-find-location-button').removeAttr('disabled');
    $('#ui-location-results').text('Lat: ' + position.coords.latitude + ' + Long: ' + position.coords.longitude);
    console.log(position);
    console.log(position.coords.latitude);
    console.log(position.coords.longitude);
  }

  function error(msg) {
    console.log(msg);
  }
});