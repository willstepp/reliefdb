var mapwindow;
var ilng;
var ilat;
var loaded = false;

function delayedpan() {
  if (mapwindow.done) {
    mapwindow.recenter(ilng, ilat);
  } else {
    window.setTimeout('delayedpan()', 500);
  }
}

var icon_num = 64;
function nexticonlet() {
  if (icon_num == 90) {
    icon_num = 97;
  } else if (icon_num == 122) {
    icon_num = 65
  } else {
    icon_num++;
  }
  return String.fromCharCode(icon_num);
}
function writeIconLet() {
  document.write(nexticonlet());
}

