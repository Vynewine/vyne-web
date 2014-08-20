json.array!(@grapes) do |grape|
  json.extract! grape, :id, :grapename_id, :quantity
  json.url grape_url(grape, format: :json)
end
