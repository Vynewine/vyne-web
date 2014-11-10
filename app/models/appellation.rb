class Appellation < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :region
end
