class MailingList < ActiveRecord::Base
  acts_as_paranoid

  has_many :subscribers
end