json.array!(@wine_allergies) do |wine_allergy|
  json.extract! wine_allergy, :id, :name
  json.url wine_allergy_url(wine_allergy, format: :json)
end
