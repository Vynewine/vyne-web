class Region < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :country
  belongs_to :appellation

  validates :name, :country_id, :presence => true

  def dropdown_label
    label = ''

    unless country.blank?
      label += "#{country.name} - "
    end

    label += name

  end
end
