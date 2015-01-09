module InventoryImporter
  # TODO need to return status and errors
  # Move this to QUEUE?
  def import_inventory(file, warehouse)

    inventory_data = Roo::CSV.new(file)

    header = inventory_data.row(1)

    if validate_inventory_data(inventory_data)

      categories = Category.all

      (2..inventory_data.last_row).each do |i|
        row = Hash[[header, inventory_data.row(i)].transpose]
        key = row['wine_key']

        wine = Wine.find_by(wine_key: key)

        inventory_item = Inventory.find_by(wine: wine, warehouse: warehouse)

        if inventory_item.nil?

          Inventory.create!(
              :warehouse => warehouse,
              :wine => wine,
              :cost => row['cost'],
              :quantity => row['quantity'],
              :vendor_sku => row['vendor_sku'],
              :category => assign_category(categories, row['cost'])[0]
          )
        else
          inventory_item.update(
              :cost => row['cost'],
              :quantity => row['quantity'],
              :category => assign_category(categories, row['cost'])[0]
          )
        end

        Sunspot.index! [wine]

      end
    end
  end

  def validate_inventory_data(data)
    header = data.row(1)
    (2..data.last_row).each do |i|

      row = Hash[[header, data.row(i)].transpose]
      wine_key = row['wine_key']
      if wine_key.nil?
        puts 'Wine key cannot be empty'
        return false
      end
    end
  end

  def assign_category(categories, cost)
    cost_decimal = cost.to_f
    case
      when cost_decimal > 0 && cost_decimal < 8.50
        return categories.select{ |category| category.name == 'House' }
      when cost_decimal >= 8.50 && cost_decimal < 13.0
        return categories.select{ |category| category.name == 'Reserve' }
      when cost_decimal >= 13.0 && cost_decimal < 23.0
        return categories.select{ |category| category.name == 'Fine' }
      when cost_decimal >= 23.0 && cost_decimal < 40.0
        return categories.select{ |category| category.name == 'Cellar' }
    end
    return [nil]
  end
end