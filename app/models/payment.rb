class Payment < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user
  # enum brand: [ :visa, :master, :american, :discover, :diners, :jcb ]
end
