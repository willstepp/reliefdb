json.array!(@facilities) do |facility|
  json.extract! facility, :website, :phone, :address, :headquarters, :contact_name, :twitter, :facebook
  json.url organization_facility_url(facility, format: :json)
end
