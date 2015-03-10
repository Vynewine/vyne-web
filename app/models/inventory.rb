class Inventory < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :warehouse
  belongs_to :wine
  belongs_to :category

  validates :vendor_sku, uniqueness_without_deleted: {
                           scope: :warehouse,
                           case_sensitive: false,
                           message: 'has to be unique per warehouse.'
                       }

  searchable do

    text :vendor_sku
    float :cost
    integer :category_id
    integer :warehouse_id


    text :name do
      wine.name
    end

    text :producer do
      unless wine.producer.blank?
        wine.producer.name
      end
    end

    # Single relationships
    text :country_name do
      unless wine.producer.blank? || wine.producer.country.blank?
        wine.producer.country.name
      end
    end

    text :country_alpha do
      unless wine.producer.blank? || wine.producer.country.blank?
        wine.producer.country.alpha_2
      end

    end

    text :region do
      unless wine.region.nil?
        wine.region.name
      end
    end

    text :subregion do
      unless wine.subregion.nil?
        wine.subregion.name
      end
    end

    text :appellation do
      unless wine.appellation.nil?
        wine.appellation.name
      end
    end

    text :type do
      unless wine.type.blank?
        wine.type.name
      end
    end

    text :grapes do
      unless wine.composition.nil?
        wine.composition.composition_grapes.map { |comp| comp.grape.name }
      end
    end

    text :txt_vintage do
      wine.txt_vintage
    end

    text :note do
      wine.note
    end

    boolean :single_estate do
      wine.single_estate
    end
  end
end
