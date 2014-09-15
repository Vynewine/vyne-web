json.array!(@statuses) do |status|
  json.extract! status, :id, :label
  json.url status_url(status, format: :json)
end
