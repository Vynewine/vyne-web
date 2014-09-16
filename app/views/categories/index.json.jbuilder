json.array!(@categories) do |category|
  json.extract! category, :id, :name, :price, :restaurant_price, :description
  json.url category_url(category, format: :json)
end
