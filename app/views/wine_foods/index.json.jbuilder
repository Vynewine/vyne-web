json.array!(@wine_foods) do |wine_food|
  json.extract! wine_food, :id, :name
  json.url wine_food_url(wine_food, format: :json)
end
