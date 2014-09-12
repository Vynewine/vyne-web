json.array!(@orders) do |order|
  json.extract! order, :id, :warehouse_id, :client_id, :advisor_id, :wine_id, :quantity
  json.url order_url(order, format: :json)
end
