class MailingList < ActiveRecord::Base
  has_many :subscribers
end