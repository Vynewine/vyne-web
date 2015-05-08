json.status 'success'
json.data do

  json.cart do
    json.merge! @cart.attributes
    json.cart_items(@cart.cart_items) do |cart_item|
      json.merge! cart_item.attributes
      json.food_items(cart_item.food_items) do |food_item|
        json.merge! food_item.attributes
      end
    end
  end
end