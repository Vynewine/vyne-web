json.order do
  json.(@order, :id, :order_schedule, :created_at, :total_price, :delivery_price, :estimated_total_max_price,
      :estimated_total_min_price, :advisory_completed_at, :order_change_timeout_seconds, :can_request_substitution? )

  json.status do
    json.id order.status.id
    json.label order.status.label
  end

  json.warehouse do
    json.title @order.warehouse.title
  end

  json.address do
    json.(@order.address, :full)
  end

  json.order_items(@order.order_items) do |item|
    json.extract! item, :id, :quantity, :price, :advisory_note

    json.category item.category, :id, :name

    wine = item.wine

    json.wine do
      json.extract! wine, :name, :id

      producer = wine.producer

      json.producer do
        json.name producer.name
        json.country producer.country, :name
      end

      json.full_info wine.full_info

      wine.region.blank? ? json.region : (json.region wine.region, :name)
      wine.subregion.blank? ? json.subregion : (json.subregion wine.subregion, :name)
      wine.locale.blank? ? json.locale : (json.locale wine.locale, :name)
      wine.appellation.blank? ? json.appellation : (json.appellation wine.appellation, :name)

      json.type wine.type, :name

      json.composition wine.compositions_array.map { |grape| grape[:name] }.join(', ')

    end
  end
end