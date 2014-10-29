json.array!(@compositions) do |composition|
  json.extract! composition, :id, :name, :region_id
  json.url composition_url(composition, format: :json)
end
