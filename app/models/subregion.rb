class Subregion < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :region

  validates :name, :region_id, :presence => true

  def dropdown_label
    label = ''

    unless region.blank?
      label += "#{region.name} - "
    end

    label += name

  end
end
