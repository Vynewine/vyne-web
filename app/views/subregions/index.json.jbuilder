json.array!(@subregions) do |subregion|
  json.extract! subregion, :id, :name, :region_id
  json.url subregion_url(subregion, format: :json)
end
