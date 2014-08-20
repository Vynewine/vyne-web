json.array!(@wine_notes) do |wine_note|
  json.extract! wine_note, :id, :name
  json.url wine_note_url(wine_note, format: :json)
end
