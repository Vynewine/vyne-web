json.array!(@payments) do |payment|
  json.extract! payment, :id, :user_id, :brand, :number, :stripe
  json.url payment_url(payment, format: :json)
end
