json.array!(@compositions) do |composition|
  json.extract! composition, :id, :grape_id, :quantity
  json.url composition_url(composition, format: :json)
end
