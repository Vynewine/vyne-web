class Locale < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :subregion
  validates :name, :subregion_id, :presence => true

  def dropdown_label
    label = ''

    unless subregion.blank?
      label += "#{subregion.name} - "
    end

    label += name

  end

end