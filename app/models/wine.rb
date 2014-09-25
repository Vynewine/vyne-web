class Wine < ActiveRecord::Base

  belongs_to :producer
  belongs_to :subregion
  belongs_to :appellation
  belongs_to :maturation
  belongs_to :order

  has_and_belongs_to_many :types
  # has_and_belongs_to_many :grapes
  has_and_belongs_to_many :occasions
  has_and_belongs_to_many :foods
  has_and_belongs_to_many :notes
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

  has_many :compositions
  has_many :grapes, through: :compositions
  accepts_nested_attributes_for :compositions

  has_many :inventories
  has_many :warehouses, through: :inventories


  # Solr & sunspot:
  searchable do
    text :name, :area
    text :type_names do # types are an association (many), so returns as array
      types.map {|type| type.name}
    end

    text :country_name do
      producer.country.name
    end

    text :txt_vintage

    integer :warehouse_ids, :multiple => true

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
