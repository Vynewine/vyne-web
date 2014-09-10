class Address < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :warehouses
  def full
  	"#{detail} #{street} #{postcode}"
  end
end
