json.array!(@grapenames) do |grapename|
  json.extract! grapename, :id, :name
  json.url grapename_url(grapename, format: :json)
end
