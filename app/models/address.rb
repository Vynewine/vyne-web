class Address < ActiveRecord::Base
  acts_as_paranoid

  has_and_belongs_to_many :users
  has_many :warehouses

  validate :set_coordinates

  def line
    "#{line_1}" + (line_2.blank? ? '' : ', ' + line_2)
  end

  def full
    ("#{line_1}" + (line_2.blank? ? '' : ', ' + line_2)) + " #{postcode}"
  end

  def longitude=(lon)
    unless lon.blank?
      @longitude = lon.to_f
    end
  end

  def latitude=(lat)
    unless lat.blank?
      @latitude = lat.to_f
    end
  end

  def longitude
    if coordinates.blank?
      ''
    else
      @longitude = coordinates.x
    end
  end

  def latitude
    if coordinates.blank?
      ''
    else
      @latitude = coordinates.y
    end
  end



  def set_coordinates

    if (@longitude.blank? && !@latitude.blank?)  || (@latitude.blank? && !@longitude.blank?)
      errors.add(:coordinates, 'longitude and latitude are required')
    end

    unless @latitude.blank? && @longitude.blank?
      self.coordinates = 'POINT(' + @longitude.to_s + ' ' + @latitude.to_s + ')'
    end
  end

  validates :postcode, length: {maximum: 250, too_long: '%{count} characters is the maximum allowed'}
  validates :line_1, length: {maximum: 250, too_long: '%{count} characters is the maximum allowed'}
  validates :line_2, length: {maximum: 250, too_long: '%{count} characters is the maximum allowed'}
  validates :company_name, length: {maximum: 250, too_long: '%{count} characters is the maximum allowed'}
end
