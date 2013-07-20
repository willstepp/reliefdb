module GeoCode
  def self.geocode(addr)
    server = XMLRPC::Client.new2('http://rpc.geocoder.us/service/xmlrpc')
    result = server.call2('geocode', addr)
    if result[1][0] != nil and result[1][0]['lat'] != nil
      return [result[1][0]['lat'], result[1][0]['long']]
    else
      nil
    end
  end
end
