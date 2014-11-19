

class Agenda < ActiveRecord::Base
  belongs_to :warehouse

  validates_uniqueness_of :day, :scope => [:warehouse]

  after_create :def_after_create

  def def_after_create
    if warehouse_id.nil?
      self.destroy
    end
  end

  def day_name
    Date::DAYNAMES[day]
  end
  def opening_time
    ("%04d" % opening).insert(2,":")
  end
  def closing_time
    ("%04d" % closing).insert(2,":")
  end
  def shutl_time(a)
    b = a/100
    c = a-b*100
    b*60+c
  end
  def shutl_opening
    shutl_time(opening)
  end
  def shutl_closing
    shutl_time(closing)
  end
end
