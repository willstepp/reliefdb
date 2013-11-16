json.array!(@resources) do |resource|
  json.extract! resource, :description
  json.url resource_url(resource, format: :json)
end
