json.array!(@inventories) do |inventory|
  json.extract! inventory, :id, :warehouse, :wine, :quantity
  json.url inventory_url(inventory, format: :json)
end
