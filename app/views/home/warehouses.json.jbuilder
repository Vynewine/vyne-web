json.warehouses do
    json.array! @warehouses do |warehouse| 
        json.id warehouse.id
        json.address warehouse.address.postcode
        json.distance Rails.application.config.max_delivery_distance
    end
end