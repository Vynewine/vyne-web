require 'test_helper'
require 'csv'

class Admin::WinesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include InventoryImporter
  include WineImporter

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    @admin = users(:admin)
    sign_in(:user, @admin)
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'can import wine inventory from CSV' do

    path = create_file

    #Pre Import Wines
    import_wines(path)

    warehouse = warehouses(:one)

    #Import Inventory
    import_inventory(path, warehouse)

    inventories = Inventory.all

    assert(inventories.select{ |inventory| inventory.wine.wine_key == 'ssb-09-c4-vado-fr-rh-ct'}.count == 1, 'Inventory items with correct wine doesn\'t exist')

  end

  def create_file
    file_path = 'wine_data.csv'

    content = []
    content << %w(wine_key name vintage single_estate alcohol composition_id type_id note bottle_size producer_id region_id subregion_id locale_id appellation_id maturation_id vinification_id vendor_sku cost quantity)
    content << ['ssb-09-c4-vado-fr-rh-ct', 'Semillon Sauvignon Blanc', '2009','FALSE','11','4','6',
                'apricots, as well as hazelnuts and fresh almonds. Several floral and spicy notes add an extra hint','75',
                producers(:three).id.to_s,regions(:four).id.to_s,subregions(:three).id.to_s,'','4','4','3','POCT20', '16.50', '89']

    CSV.open(file_path, 'wb') do |csv|
      content.each { |row| csv << row }
    end

    file_path
  end

end