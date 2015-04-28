class Producer < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :country

  validates :name, :country_id, :presence => true

  def dropdown_label
    label = ''

    label += name

    unless country.blank?
      label += " - (#{country.name})"
    end

    label

  end

end
