json.array!(@producers) do |producer|
  json.extract! producer, :id, :name, :country
  json.url producer_url(producer, format: :json)
end
