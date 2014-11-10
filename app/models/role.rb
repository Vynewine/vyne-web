class Role < ActiveRecord::Base
  acts_as_paranoid

  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  
  scopify
end
