json.array!(@appellations) do |appellation|
  json.extract! appellation, :id, :name
  json.url appellation_url(appellation, format: :json)
end
