json.array!(@maturation_types) do |maturation_type|
  json.extract! maturation_type, :id, :name
  json.url maturation_type_url(maturation_type, format: :json)
end
