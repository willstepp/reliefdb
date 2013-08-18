function hide_table_column(tableid, col_no) {

  var tbl  = document.getElementById(tableid);
  var rows = tbl.getElementsByTagName('tr');

  var heads = rows[0].getElementsByTagName('th');
  heads[col_no].style.display='none';
  for (var row=1; row<rows.length;row++) {
    var cels = rows[row].getElementsByTagName('td');
    cels[col_no].style.display='none';
  }

  if (s = document.getElementById("show_all_" + tableid)) {
    s.style.display = '';
  }
}

function show_table_column(tableid, col_no) {

  var tbl  = document.getElementById(tableid);
  var rows = tbl.getElementsByTagName('tr');

  var heads = rows[0].getElementsByTagName('th');
  heads[col_no].style.display='';
  for (var row=1; row<rows.length;row++) {
    var cels = rows[row].getElementsByTagName('td');
    cels[col_no].style.display='';
  }
}

function show_all_columns(tableid) {
  var tbl  = document.getElementById(tableid);
  var rows = tbl.getElementsByTagName('tr');

  for (var row=0; row<rows.length;row++) {
    if (row == 0) {
      var cels = rows[0].getElementsByTagName('th');
    } else {
      var cels = rows[row].getElementsByTagName('td');
    }
    for (var cel=0; cel<cels.length;cel++) {
      cels[cel].style.display='';
    }
  }
  document.getElementById("show_all_" + tableid).style.display='none';
}

