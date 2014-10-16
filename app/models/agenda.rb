class Agenda < ActiveRecord::Base
  belongs_to :warehouse
  validates :warehouse_id, :day, :presence => true
  validates_uniqueness_of :day, :scope => [:warehouse]
  def day_name
    Date::DAYNAMES[day]
  end
  def opening_time
    ("%04d" % opening).insert(2,":")
  end
  def closing_time
    ("%04d" % closing).insert(2,":")
  end
end
