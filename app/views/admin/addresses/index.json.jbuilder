json.array!(@addresses) do |address|
  json.extract! address, :id, :line_1, :line_2, :company_name, :postcode
  json.url address_url(address, format: :json)
end
