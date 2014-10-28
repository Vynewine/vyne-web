class Wine < ActiveRecord::Base

  belongs_to :producer
  belongs_to :subregion
  belongs_to :maturation
  belongs_to :order_item
  belongs_to :type
  belongs_to :vinification
  belongs_to :region
  belongs_to :locale
  belongs_to :appellation
  belongs_to :composition

  # has_and_belongs_to_many :grapes
  has_and_belongs_to_many :occasions
  has_and_belongs_to_many :foods
  has_and_belongs_to_many :allergies

  attr_accessor :occasion_tokens
  attr_accessor :food_tokens
  attr_accessor :note_tokens

  def occasion_tokens=(ids)
    self.occasion_ids = ids.split(",")
  end
  def food_tokens=(ids)
    self.food_ids = ids.split(",")
  end
  def note_tokens=(ids)
    self.note_ids = ids.split(",")
  end


  #has_many :grapes, through: :compositions:composition_grapes
  #accepts_nested_attributes_for :compositions

  has_many :inventories
  has_many :warehouses, through: :inventories

  validates :name, :producer_id, :presence => true

  # validates :compulsory_fields

  # def compulsory_fields
  #   if self.name.nil? || self.name.empty?
  #     self.errors.add(:name, "needs a name" )
  #   end
  #   if self.vintage.nil? || self.vintage.empty?
  #     self.errors.add(:vintage, "needs a vintage" )
  #   end
  #   if self.producer.nil? || self.producer_id.empty?
  #     self.errors.add(:producer_id, "needs a producer" )
  #   end
  # end


  # Solr & sunspot:
  searchable do
    text :name

    # Single relationships
    text :country_name do
      producer.country.name
    end

    text :country_alpha do
      producer.country.alpha_2
    end


    text :subregion do
      unless subregion.nil?
        subregion.name
      end
    end


    text :type do
      type.name
    end

    #TODO Review this. I think grapes go through compositions.
    # text :grapes do
    #   grapes.map {|g| g.name}
    # end

    text :foods do
      foods.map {|f| f.name}
    end

    text :txt_vintage

    boolean :single_estate
    # boolean :vegan
    # boolean :organic

    text :note

    integer :warehouse_ids, :multiple => true

    integer :price_categories, :multiple => true do
      inventories.all.map do |i|
        unless i.category.nil?
          i.category.id
        end
      end
    end

    # integer :warehouse_id do
    #   warehouses.id #map {|i| i.warehouse_id}
    # end

    # integer :producer_id
    # integer :subregion_id

    # integer :type_ids, :multiple => true
    # string  :sort_title do
    #   title.downcase.gsub(/^(an?|the)/, '')
    # end

    # boolean text string time double
  end

  def txt_vintage
    #TODO: if nil display NV - Non Vintage if 0 display Unknown
    vintage.to_s
  end

  def compositions_array
    comp = []
    compositions.each do |c|
      comp.push( { :name => c.grape.name, :quantity => c.quantity} )
    end
    return comp
  end

end
