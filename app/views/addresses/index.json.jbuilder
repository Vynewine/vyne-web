json.array!(@addresses) do |address|
  json.extract! address, :id, :street, :detail, :postcode
  json.url address_url(address, format: :json)
end
