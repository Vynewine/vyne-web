json.array!(@results) do |wine|
  json.name wine.name
  json.vintage wine.vintage
  json.type wine.types
end