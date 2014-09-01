json.array!(@warehouses) do |warehouse|
  json.extract! warehouse, :id, :title, :address_id
  json.url warehouse_url(warehouse, format: :json)
end
