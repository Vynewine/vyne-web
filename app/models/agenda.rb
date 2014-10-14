class Agenda < ActiveRecord::Base
  belongs_to :warehouse
  def day_name
    Date::DAYNAMES[day-1]
  end
  def opening_time
    ("%04d" % opening).insert(2,":")
  end
  def closing_time
    ("%04d" % closing).insert(2,":")
  end
end
