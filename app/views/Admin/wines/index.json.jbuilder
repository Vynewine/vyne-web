json.array!(@wines) do |wine|
  json.extract! wine, :id, :name, :vintage, :area, :single_estate, :alcohol, :sugar, :acidity, :ph, :vegetarian, :vegan, :organic
  json.url wine_url(wine, format: :json)
end
