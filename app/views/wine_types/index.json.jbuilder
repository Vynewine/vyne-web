json.array!(@wine_types) do |wine_type|
  json.extract! wine_type, :id, :name
  json.url wine_type_url(wine_type, format: :json)
end
