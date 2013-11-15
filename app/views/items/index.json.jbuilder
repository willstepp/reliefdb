json.array!(@items) do |item|
  json.extract! item, :description, :stock
  json.url item_url(item, format: :json)
end
