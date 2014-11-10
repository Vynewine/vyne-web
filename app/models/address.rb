class Address < ActiveRecord::Base
  acts_as_paranoid

  has_and_belongs_to_many :users
  has_many :warehouses
  def line
    "#{detail} #{street}"
  end
  def full
    "#{detail} #{street} #{postcode}"
  end
  validates :postcode, length: { maximum: 250, too_long: '%{count} characters is the maximum allowed'}
  validates :street, length: { maximum: 250, too_long: '%{count} characters is the maximum allowed'}
  validates :detail, length: { maximum: 250, too_long: '%{count} characters is the maximum allowed'}
end
