json.array!(@maturations) do |maturation|
  json.extract! maturation, :id, :maturation_type_id, :period
  json.url maturation_url(maturation, format: :json)
end
