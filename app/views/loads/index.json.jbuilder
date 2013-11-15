json.array!(@loads) do |load|
  json.extract! load, :description, :stock
  json.url load_url(load, format: :json)
end
