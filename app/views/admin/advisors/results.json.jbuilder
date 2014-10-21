require 'sprockets/railtie'

json.array!(@results) do |wine|
  # Origin info
  json.countryCode wine.producer.country.alpha_2
  json.countryFlag asset_path(wine.producer.country.alpha_2 + '.png')
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
  json.compositions wine.compositions.map { |c| { :name => c.grape.name, :quantity => c.quantity }}
  json.notes wine.notes.map {|n| n.name}
  
  # Availability
  json.availability do
    json.array!(wine.inventories) do |inventory|
      json.warehouse inventory.warehouse_id
      json.agendas   inventory.warehouse.agendas
      json.cost      inventory.cost
      json.price     inventory.category.price
      json.quantity  inventory.quantity
      json.category  inventory.category
    end
  end

end