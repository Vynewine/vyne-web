json.array!(@allergies) do |allergy|
  json.extract! allergy, :id, :name
  json.url allergy_url(allergy, format: :json)
end
