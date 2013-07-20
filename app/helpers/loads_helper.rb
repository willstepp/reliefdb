module LoadsHelper

  def autoselect_trucker
    out = javascript_tag "
      function set_trucker(str) {
        fields = str.split(' / ');
        document.getElementById('load_trucker_name').value = fields[0];
        document.getElementById('load_truck_reg').value = fields[1];
      }
    "
    fields = 'trucker_name, truck_reg'
    rows = ActiveRecord::Base.connection.select_all("SELECT #{fields} FROM loads GROUP BY #{fields} ORDER BY #{fields};")
    vals = rows.map {|r| "#{r['trucker_name']} / #{r['truck_reg']}" }
    vals.unshift " / "
    out << "<select id=\"load_trucker\" onchange=\"set_trucker(this.value)\">"
    out << options_for_select(vals) + "</select>"
    return out
  end

end
