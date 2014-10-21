json.warehouses do
    json.array! @warehouses do |warehouse| 
        json.id warehouse.id
        json.address warehouse.address.postcode
        json.distance 2.5
    end
end