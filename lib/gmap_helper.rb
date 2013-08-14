# Generates a google-map in your rhtml
#
# == Installation
#
# - Put this file (gmap_helper.rb) in your Rails.root.to_s/lib/ directory
# - Include the file in your Rails.root.to_s/app/helpers/application_helper.rb 
#
#   module ApplicationHelper
#    include GmapHelper
#
# == Including the google script in your header
#
#  <html>
#  <head>
#   <%= header("12345-ABCDEF-your-api-key-from-google") %>
#  </head>
#  <body>
#
# == Making a map in your document
#
# <%= gmap :option=>value, :option2=>value, .. %>
#
module GmapHelper

  # Generates the script for the <head> of your html
  # You want to include this in all your templates that will have maps in them
  #
  # Usage:
  #  (in your .rhtml template)
  #
  #  <html>
  #  <head>
  #   <%= header("12345-ABCDEF-your-api-key-from-google") %>
  #  </head>
  #  <body>
  #
  # Note that you will probably have more stuff in there :)
  #
  def header(api_key)
  	"<!--[if IE]>
  	 <style type=\"text/css\">
  	     v\\:* { behavior:url(#default#VML); }
  	 </style>
  	 <![endif]-->
  	 <script src='http://maps.google.com/maps?file=api&amp;v=1&amp;key=#{api_key}' type='text/javascript'></script>"
  end

  # Generates a google-map in your rhtml
  #
  # Usage:
  # 
  # <%= gmap({options}) %>
  #
  #
  # == Options (all these are optional):
  #
  # [:mapname]   set the name of the map (this is used for refering to the map with javascript, later)   
  #              mapnames should be unique, if you have more than one on a page.
  # [:width]     set the width of the map, in pixels (default 400)
  # [:height]    set the height of the map, in pixels (default 400)
  # [:point]     an array containing latitute, longitude like [-114.123, 23.2563]
  # [:marker]    overlays a marker, boolean (uses :point coordinates), or an array containing a coordinate pair, defaults to false
  # [:polyline]  overlays a line, an array containing coordinate pairs [[-114.123, 23.2563], [-114.133, 23.2573]], defaults to false
  # [:type]      set the default type of map (:map or :satellite) defaults to :map
  # [:dragging]  => :disabled turns off dragging of the map
  # [:icon]      => :small provides a smaller style icon, ala ridefinder
  #
  # [:click]     => executes javascript when the map is clicked. you can access 'pt' which is an object with two methods, pt.x and pt.y.  Example, :click=>'alert(pt.x + "," + pt.y);'
  # [:info_window]  display an information window containing text in the center of the map like :info_window=>'hello!'
  # [:controls]  display controls in the map; takes any of the following (use an array for multiples)
  #  :large  large controls
  #  :small  small controls
  #  :zoom   zoom in and out
  #  :type   select satellite/map view
  # example :controls=>[:small,:zoom,:type]
  #
  # [:white_div]  a hash; if included, will show a white bar under the 'powered by google' stuff, so that your map looks a little cleaner. use like :white_div=>{:background_color=>'white'}
  #   :background_color  html-style backgroundColor, a string like 'white', 'red', or '#fff')
  #   :border_top        :border_top => true for a gray top border
  #   :height            :height=>50  for a 50px high bar. default to 25px
  #
  # == Examples: 
  #
  #  gmap(:mapname=>"my_map", :width=>"50", :height=>"120")
  #
  #  gmap(:width=>"500", :height=>"500", :type=>:satellite, :point=>[-122.14944, 37.441944])
  #
  #  gmap(:mapname=>"foo", :white_div=>{:background_color=>'black', :height=>'40'})
  #
  def gmap(options={})
	 # setup defaults
	 mapname	= options[:name] ||= 'map'

    #options[:width]  ||= 400
    #options[:height] ||= 400
    options[:point]  ||= [-122.141944, 37.441944]

	 #options[:width] << 'px' unless options[:width] =~ /^\d+(px|em|\%)$/
	 #options[:height] << 'px' unless options[:width] =~ /^\d+(px|em|\%)$/
		
	 out = []  

    #out << "<div id='#{mapname}' style='width:#{options[:width].to_s};height:#{options[:height].to_s}'></div>    	
    out << "<div id='#{mapname}' style='width:100%;height:100%'></div>    	
    <script type='text/javascript'>
    //<![CDATA[ 
    var #{mapname};
    var #{mapname}center = new GPoint(#{options[:point][0]}, #{options[:point][1]});

    function load_gmap() {
    	#{mapname} = (new GMap(document.getElementById('#{mapname}')));
    	#{mapname}.centerAndZoom(#{mapname}center, #{options[:zoom] || 2});"

    if options[:type] == :satellite
    	out << "#{mapname}.setMapType(#{mapname}.mapTypes[1]);" # gmaps bug! this will break in future.
    end

    if options[:icon] == :small
      out << "var icon = new GIcon();"
      out << "icon.image = \"http://labs.google.com/ridefinder/images/mm_20_red.png\";"
      out << "icon.shadow = \"http://labs.google.com/ridefinder/images/mm_20_shadow.png\";"
      out << "icon.iconSize = new GSize(12, 20);"
      out << "icon.shadowSize = new GSize(22, 20);"
      out << "icon.iconAnchor = new GPoint(6, 20);"
    end

	 # todo: extend this to show images or other types of nodes in the info window
    if options[:info_window]
      out << "#{mapname}.openInfoWindow(#{mapname}.getCenterLatLng(), document.createTextNode('#{options[:info_window] || "Hello, world!"}'));"
    end
    if [:disabled, false].include?options[:dragging]
    	out << "#{mapname}.disableDragging();"
    end

    # iterate through all control/s
    options[:controls] = [options[:controls]] if !options[:controls].is_a?Array
    options[:controls].each do |control|
      case control
        when :large
          out << "#{mapname}.addControl(new GLargeMapControl());"
        when :small
          out << "#{mapname}.addControl(new GSmallMapControl());"
        when :zoom
          out << "#{mapname}.addControl(new GSmallZoomControl());"
        when :type
          out << "#{mapname}.addControl(new GMapTypeControl());"
      end
    end

    # creates a marker at the specified point or the average of polyline coordinates
    out << create_marker(options) if options[:marker]

    # creates a line using the array of points given
     if options[:polyline].is_a?(Array)
       @linepoints = []
       options[:polyline].each do |p| 
         @linepoints << "new GPoint(#{p.join(",")}) "
       end
       out << " var polyline = new GPolyline([#{@linepoints.join(",")}]);"
       out << " #{mapname}.addOverlay(polyline);"
     end 

     

     if options[:white_div]
     	out << "create_skirt_div_for_#{mapname}(); "
     end

	  # click point is pt.x and pt.y
     if options[:click]
	    out << "GEvent.addListener(mymap, 'click', function(overlay, point) {"
	    out << "  if (overlay) pt = overlay;"
	    out << "  else if (point) pt = point; "
	    out << "  #{options[:click]}; "
		 out << "});"
     end

 
	  # note to developers: 
	  # put any map-related code above this line. because the map only
	  # loads after the page has loaded (due to IE), anything referencing
	  # your map won't work unless it is in this function, because it won't
	  # exist yet.
	
	  out << "}"
	
	  
	  if options[:white_div]
	  	 out << div_beneath_logo(mapname, options[:white_div])
	  end
	
		out << "
	  if (typeof window.onload != 'function')
     	window.onload = load_gmap;
	  else {
		old = window.onload;
		window.onload = function() {old();load_gmap();};
	  }
	"

     out << "//]]>"
     out << "</script>"
     return out.join(13.chr + "    	") #preserve whitespacing :)
  end

  # Show a link to reset a map to its initial centering
  # <%= gmap__reset_to_center('your_map_name', {:zoom=>5, :text=>'reset map!'})
  # renders as 
  # <a href='#' onclick='(some javascript)'>reset map!</a>
  def gmap__reset_to_center(mapname = "map", options = {})
    "<a href='#' onclick='#{mapname}.centerAndZoom(#{mapname}center, #{options[:zoom] || 2}); return false'>#{options[:text] || 'Reset map'}</a>"
  end

protected

  # creates a white div underneath the google logo, so it looks nicer.
  # usage (from gmap method):
  #  gmap(:white_div=>{:background_color=>'white', :border_top=>true, :height=>50})
  def div_beneath_logo(mapname = 'map', options={}) #nodoc
	 ret = "

function create_skirt_div_for_#{mapname}()
{
   var div = document.createElement('DIV');
   div.style.backgroundColor = '#{options[:background_color]||white}';
   div.style.position = 'absolute';
   div.style.left = '0';
   div.style.bottom = '-1px';
   div.style.padding = '0';
	div.style.height = '#{(options[:height] || 25).to_s}px';
	"
	ret << "div.style.borderTop = '1px solid #aaa';" 	if options[:borderTop] 
	ret << "
	var my_gmap_DOM_element = document.getElementById('#{mapname}');
   my_gmap_DOM_element.appendChild(div);
   div.style.width = '100%';

 	var divs = my_gmap_DOM_element.getElementsByTagName('DIV');
 	divs[1].style.zIndex = '1000';
 	for (var i=2; i<=3; i++) {
	   divs[i].style.zIndex = '1000';
	   divs[i].style.wordWrap = 'break-word';
	   divs[i].style.width = '50%';
	   divs[i].style.fontSize = '80%';
	}
}
  "
  end

  # returns the average (very unscientificly) 
  # of several coordinates
  def average_points(linepoints=[])
    long_sum = 0.00
    lat_sum  = 0.00
    linepoints.uniq.each do |p| 
      long_sum += p[0].to_f
      lat_sum  += p[1].to_f
    end
    average_longitude = long_sum / linepoints.uniq.size
    average_latitude  = lat_sum  / linepoints.uniq.size
    [average_longitude,average_latitude]
  end

  def self.map_icon_number(i, color)
    if i == -1
      return "http://www.geekspace.com/mapicons/marker-" + color.upcase + "-DOT.png"
    else 
      return "http://www.geekspace.com/mapicons/marker-" + color.upcase + "-" + map_letter_number(i) + ".png"
    end
  end

  @@LETTERS = (65..90).map {|i| i.chr} + (97..122).map {|i| i.chr}
  def self.map_letter_number(i)
    i = i % @@LETTERS.size
    @@LETTERS[i]
  end

  def map_icon_number(i, color)
    GmapHelper.map_icon_number(i, color)
  end

  def create_marker(options)
	  out = []
          if options[:marker].is_a?(Hash)
	    # Google sample code
	    out << '
	      // Create a base icon for all of our markers that specifies the shadow, icon
	      // dimensions, etc.
	      var baseIcon = new GIcon();
	      baseIcon.shadow = "http://www.google.com/mapfiles/shadow50.png";
	      baseIcon.iconSize = new GSize(20, 34);
	      baseIcon.shadowSize = new GSize(37, 34);
	      baseIcon.iconAnchor = new GPoint(9, 34);
	      baseIcon.infoWindowAnchor = new GPoint(9, 2);
	      baseIcon.infoShadowAnchor = new GPoint(18, 25);

	      // Creates a marker whose info window displays the letter corresponding to
	      // the given index
	      function createMarker(point, iconsrc, text) {
		// Create a lettered icon for this point using our icon class from above
	        var icon = new GIcon(baseIcon);
		icon.image = iconsrc;
		var marker = new GMarker(point, icon);

		// Show this marker\'s index in the info window when it is clicked
		GEvent.addListener(marker, "click", function() {
		  marker.openInfoWindowHtml(text);
		});

	        return marker;
	      }
	    '
	    options[:marker].each { |index, p|
              latlong, desc, color, selected = p
              index = -1 if selected
	      out << " var marker = createMarker(new GPoint(#{latlong.join(",")}), '#{map_icon_number(index, color)}', '#{desc}');"
	      out << " #{options[:name]}.addOverlay(marker);"
	    }
	  else
  	    if options[:polyline].is_a?Array
  	      marker_point = options[:marker].is_a?(Array) ? options[:marker] : average_points(options[:polyline])
  	    else 
  	      marker_point = (options[:marker] and options[:marker].is_a?(Array)) ? options[:marker] : options[:point]
  	    end
  	    if options[:icon] == :small
  	      out << " var marker = new GMarker(new GPoint(#{marker_point.join(",")}), icon);"
  	    else
  	      out << " var marker = new GMarker(new GPoint(#{marker_point.join(",")}));"
  	    end
  	    out << " #{options[:name]}.addOverlay(marker);"
          end
	  out	
  end


end
