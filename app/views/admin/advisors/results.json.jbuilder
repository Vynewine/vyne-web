require 'sprockets/railtie'

json.array!(@results) do |wine|
  # Origin info
  json.countryCode wine[:countryCode]
  json.countryFlag asset_path('flags/' + wine[:countryCode] + '.png')
  json.countryName wine[:countryName]
  json.region wine[:region]
  json.subregion wine[:subregion]
  json.locale wine[:locale]
  # Wine info
  json.id wine[:id]
  json.appellation wine[:appellation]
  json.name wine[:name]
  json.vintage wine[:vintage]
  json.single_estate wine[:single_estate]
  json.bottle_size wine[:bottle_size].blank? ? '' : wine[:bottle_size].to_i
  json.vendor_sku wine[:vendor_sku]
  json.producer wine[:producer]

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
  json.inventory_id wine[:inventory_id]

end