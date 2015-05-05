json.status 'success'
json.data do

  json.cart do
    json.merge! @cart.attributes
    json.(@cart, :cart_items)
  end
end