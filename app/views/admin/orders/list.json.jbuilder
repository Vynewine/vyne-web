json.array!(@orders) do |order|
  # json.extract! order, :id, :client_id
  json.id order.id
  json.client order.client
  json.information order.information
  json.address order.address
  # json.warehouse order.warehouse
end
