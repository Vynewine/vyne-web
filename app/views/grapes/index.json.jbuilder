json.array!(@grapes) do |grape|
  json.extract! grape, :id, :name
  json.url grape_url(grape, format: :json)
end
