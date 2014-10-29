require 'sprockets/railtie'

json.array!(@results) do |wine|
  # Origin info
  json.countryCode wine[:countryCode]
  json.countryFlag asset_path(wine[:countryCode] + '.png')
  json.countryName wine[:countryName]
  json.subregion wine[:subregion]
  # Wine info
  json.id wine[:id]
  json.appellation wine[:appellation]
  json.name wine[:name]
  json.vintage wine[:vintage]
  json.single_estate wine[:single_estate]

  # Relationships
  json.type wine[:type]
  json.compositions wine[:compositions]
  json.note wine[:note]
  # Availability
  json.warehouse wine[:warehouse]
  json.agendas wine[:agendas]
  json.cost wine[:cost]
  json.price wine[:price]
  json.quantity  wine[:quantity]
  json.category  wine[:category]
  json.warehouse_distance wine[:warehouse_distance]
end