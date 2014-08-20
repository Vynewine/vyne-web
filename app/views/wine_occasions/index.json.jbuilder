json.array!(@wine_occasions) do |wine_occasion|
  json.extract! wine_occasion, :id, :name
  json.url wine_occasion_url(wine_occasion, format: :json)
end
