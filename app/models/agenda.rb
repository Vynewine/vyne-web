class Agenda < ActiveRecord::Base
  belongs_to :warehouse
  # validates :warehouse_id, :day, :presence => true
  validates_uniqueness_of :day, :scope => [:warehouse]
  # after_update :delete_if_null

  # def delete_if_null
  #   if warehouse_id.nil?
  #   end
  # end



  # # valid
  # before_validation :def_before_validation
  # # validate
  # after_validation :def_after_validation
  # before_save :def_before_save
  # before_create :def_before_create
  # # create
  after_create :def_after_create
  # after_save :def_after_save
  # after_commit :def_after_commit


  # def def_before_validation
  #   puts "[#{id}] [#{warehouse_id}] [#{day}] [#{opening}] [#{closing}] - def_before_validation"
  # end
  # def def_after_validation
  #   puts "[#{id}] [#{warehouse_id}] [#{day}] [#{opening}] [#{closing}] - def_after_validation"
  # end
  # def def_before_save
  #   puts "[#{id}] [#{warehouse_id}] [#{day}] [#{opening}] [#{closing}] - def_before_save"
  # end
  # def def_before_create
  #   puts "[#{id}] [#{warehouse_id}] [#{day}] [#{opening}] [#{closing}] - def_before_create"
  # end
  def def_after_create
    # puts "[#{id}] [#{warehouse_id}] [#{day}] [#{opening}] [#{closing}] - def_after_create"
    if warehouse_id.nil?
      self.destroy
    end
  end
  # def def_after_save
  #   puts "[#{id}] [#{warehouse_id}] [#{day}] [#{opening}] [#{closing}] - def_after_save"
  # end
  # def def_after_commit
  #   puts "[#{id}] [#{warehouse_id}] [#{day}] [#{opening}] [#{closing}] - def_after_commit"
  # end

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
