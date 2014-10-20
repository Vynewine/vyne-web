json.array!(@bottlings) do |bottling|
  json.extract! bottling, :id, :name
  json.url bottling_url(bottling, format: :json)
end
