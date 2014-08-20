json.array!(@wine_maturations) do |wine_maturation|
  json.extract! wine_maturation, :id, :maturation_type_id, :period
  json.url wine_maturation_url(wine_maturation, format: :json)
end
