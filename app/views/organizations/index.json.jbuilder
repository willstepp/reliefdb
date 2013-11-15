json.array!(@organizations) do |organization|
  json.extract! organization, :name, :email, :phone
  json.url organization_url(organization, format: :json)
end
