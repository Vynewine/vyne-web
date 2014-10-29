json.array!(@vinifications) do |vinification|
  json.extract! vinification, :id, :vinification_type_id, :period
  json.url vinification_url(vinification, format: :json)
end
