module InventoryImporter

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Wine Importer'

  def self.import_inventory(file, warehouse)

    result = {
        :errors => []
    }

    begin

    inventory_data = Roo::CSV.new(file)

    header = inventory_data.row(1)

    validation_error = validate_inventory_data(inventory_data)

    puts json: validation_error

    if validation_error.blank?

      categories = Category.all

      (2..inventory_data.last_row).each do |i|
        row = Hash[[header, inventory_data.row(i)].transpose]
        key = row['wine_key']

        wine = Wine.find_by(wine_key: key)

        inventory_item = Inventory.find_by(wine: wine, warehouse: warehouse)

        if inventory_item.nil?

          inv = Inventory.new(
              :warehouse => warehouse,
              :wine => wine,
              :cost => row['cost'],
              :quantity => row['quantity'],
              :vendor_sku => row['vendor_sku'],
              :category => assign_category(categories, row['cost'])[0]
          )

          unless inv.save
            result[:errors] << inv.errors.full_messages().join(', ')
            result[:errors] << row['vendor_sku']
            return
          end

        else
          inventory_item.update(
              :cost => row['cost'],
              :quantity => row['quantity'],
              :category => assign_category(categories, row['cost'])[0],
              :vendor_sku => row['vendor_sku']
          )
        end

        Sunspot.index! [wine]

      end
    else
      result[:errors] << validation_error
    end

    rescue Exception => exception
      message = "Error occurred while importing inventory: #{exception.class} - #{exception.message}"
      Rails.logger.error message
      Rails.logger.error exception.backtrace
      result[:errors] << message
    ensure
      return result
    end
  end

  def self.validate_inventory_data(data)

    error = nil

    begin
      header = data.row(1)
      (2..data.last_row).each do |i|

        row = Hash[[header, data.row(i)].transpose]
        wine_key = row['wine_key']
        vendor_sku = row['vendor_sku']
        if wine_key.blank?
          error = 'Wine key cannot be empty'
          return
        end
        if vendor_sku.blank?
          error = 'Vendor sku cannot be empty'
          return
        end
      end
    ensure
      return error
    end

  end

  def self.assign_category(categories, cost)
    cost_decimal = cost.to_f
    case
      when cost_decimal > 10 && cost_decimal < 15.0
        return categories.select{ |category| category.name == 'House' }
      when cost_decimal >= 15.01 && cost_decimal < 20.0
        return categories.select{ |category| category.name == 'Reserve' }
      when cost_decimal >= 20.01 && cost_decimal < 30.0
        return categories.select{ |category| category.name == 'Fine' }
      when cost_decimal >= 30.01 && cost_decimal < 50.0
        return categories.select{ |category| category.name == 'Cellar' }
    end
    return [nil]
  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end

  def self.log_warning(message)
    @logger.tagged(TAG) { @logger.warn message }
  end

  def self.log_error(message)
    @logger.tagged(TAG) { @logger.error message }
  end
end