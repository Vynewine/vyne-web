require 'test_helper'
require 'csv'

class Admin::WinesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include WineImporter

  def setup
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    @admin = users(:admin)
    sign_in(:user, @admin)
  end

  def teardown
    Sunspot.session = Sunspot.session.original_session
  end

  test 'can import wines from CSV' do

    CSV.open('wine_data.csv', 'wb') do |csv|
      csv << %w(name vintage single_estate alcohol composition_id type_id note bottle_size producer_id region_id subregion_id locale_id appellation_id maturation_id vinification_id)
      csv << ['Semillon Sauvignon Blanc', '2009','FALSE','11','4','6',
              'apricots, as well as hazelnuts and fresh almonds. Several floral and spicy notes add an extra hint','75',
              producers(:three).id.to_s,regions(:four).id.to_s,subregions(:three).id.to_s,'','4','4','3']
    end

    file_path = 'wine_data.csv'#"/Users/jakub/Development/Vynz/docs/inventory-documents-export-2014-10-25/Upload wine data.csv"
    import_wines(file_path)
    wines = Wine.all
    assert(wines.select{ |wine| wine.wine_key == 'ssb-09-c4-vado-fr-rh-ct'}.count == 1)
  end

  test 'will convert names' do
    assert_equal('c', convert_name_to_key_part('Côte'))
    assert_equal('cdnvb', convert_name_to_key_part('Côte de Nuits Villages Blanc'))
    assert_equal('rg', convert_name_to_key_part('Ribolla Gialla'))
    assert_equal('r', convert_name_to_key_part('Ribolla'))
    assert_equal('3csr', convert_name_to_key_part('34 Cabernet Sauvignon/Merlot Rose'))
    assert_equal('rdrb', convert_name_to_key_part("R' de Ruinart Brut"))
  end

  test 'will convert vintage' do
    assert_equal('nv', convert_vintage_to_key_part(nil), 'Should equal nv')
    assert_equal('uv', convert_vintage_to_key_part(0), 'Should equal uv')
    assert_equal('04', convert_vintage_to_key_part(2004), 'Should equal 04')
  end

  test 'will convert producer name' do
    assert_equal('vado-fr', convert_producer_to_key_part(producers(:three).id))
    assert_equal('jede-it', convert_producer_to_key_part(producers(:four).id))
    assert_equal('fe-fr', convert_producer_to_key_part(producers(:five).id))
  end

  test 'will convert region name' do
    assert_equal('an', convert_region_to_key_part(regions(:three).id))
    assert_equal('rh', convert_region_to_key_part(regions(:four).id))
    assert_equal('to', convert_region_to_key_part(regions(:five).id))
    assert_equal('_', convert_region_to_key_part(nil))
    assert_equal('_', convert_region_to_key_part(''))
  end

  test 'will convert subregion name' do
    assert_equal('ct', convert_subregion_to_key_part(subregions(:three).id))
    assert_equal('ga', convert_subregion_to_key_part(subregions(:four).id))
    assert_equal('st', convert_subregion_to_key_part(subregions(:five).id))
    assert_equal('_', convert_subregion_to_key_part(nil))
    assert_equal('_', convert_subregion_to_key_part(''))
  end

  test 'will convert bottle size' do
    assert_equal('', convert_bottle_size_to_key_part(75))
    assert_equal('76', convert_bottle_size_to_key_part(76))
    assert_equal('150', convert_bottle_size_to_key_part(150))
  end

  test 'will create key' do
    row1 = {
        'name' => "R' de Ruinart Brut",
        'vintage' => '2004',
        'producer_id' => producers(:three).id.to_s,
        'region_id' => regions(:four).id.to_s,
        'subregion_id' => '',
        'bottle_size' => '150',
        'composition_id' => compositions(:one).id.to_s
    }

    row2 = {
        'name' => "R' de Ruinart Brut",
        'vintage' => '2004',
        'producer_id' => producers(:three).id.to_s,
        'region_id' => regions(:four).id.to_s,
        'subregion_id' => '',
        'bottle_size' => '75',
        'composition_id' => compositions(:one).id.to_s
    }

    row3 = {
        'name' => "R' de Ruinart Brut",
        'vintage' => '2004',
        'producer_id' => producers(:three).id.to_s,
        'region_id' => regions(:four).id.to_s,
        'subregion_id' => subregions(:three).id.to_s,
        'bottle_size' => '75',
        'composition_id' => compositions(:one).id.to_s
    }

    row4 = {
        'name' => "R' de Ruinart Brut",
        'vintage' => '2004',
        'producer_id' => producers(:three).id.to_s,
        'region_id' => regions(:four).id.to_s,
        'subregion_id' => subregions(:three).id.to_s,
        'bottle_size' => '100',
        'composition_id' => compositions(:one).id.to_s
    }

    assert_equal('rdrb-04-c' + compositions(:one).id.to_s + '-vado-fr-rh-150' , create_wine_key(row1))
    assert_equal('rdrb-04-c' + compositions(:one).id.to_s + '-vado-fr-rh', create_wine_key(row2))
    assert_equal('rdrb-04-c' + compositions(:one).id.to_s + '-vado-fr-rh-ct', create_wine_key(row3))
    assert_equal('rdrb-04-c' + compositions(:one).id.to_s + '-vado-fr-rh-ct-100', create_wine_key(row4))
  end


end