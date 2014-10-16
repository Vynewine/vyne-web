json.array!(@results) do |wine|
  # Origin info
  json.countryCode wine.producer.country.alpha_2
  json.countryName wine.producer.country.name
  json.subregion wine.subregion.nil? ? '' : wine.subregion.name

  # Wine info
  json.id wine.id
  json.appellation wine.appellation.name
  json.name wine.name
  json.vintage wine.vintage
  json.single_estate wine.single_estate
  json.vegan wine.vegan
  json.organic wine.organic

  # Relationships
  json.types wine.types.map {|t| t.name}
  json.compositions wine.compositions_array
  json.notes wine.notes.map {|n| n.name}
  
  # Availability
  json.availability do
    # wine.inventories.each do |inventory|
    json.array!(wine.inventories) do |inventory|
      json.warehouse inventory.warehouse_id
      json.agendas   inventory.warehouse.agendas

      # json.array!(inventory.warehouse.agendas) do |agenda|
      #   json.day agenda.
      # end

      json.price     inventory.category.price
      json.quantity  inventory.quantity
    end
  end

end