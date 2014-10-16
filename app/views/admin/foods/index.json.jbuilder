json.array!(@foods) do |food|
  json.extract! food, :id, :name
  json.url admin_food_url(food, format: :json)
end
