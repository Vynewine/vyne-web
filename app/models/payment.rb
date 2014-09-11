class Payment < ActiveRecord::Base
  belongs_to :user
  # enum brand: [ :visa, :master, :american, :discover, :diners, :jcb ]
end
