class Subscriber < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :mailing_list
end