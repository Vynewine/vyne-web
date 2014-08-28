class User < ActiveRecord::Base
  after_create :assign_default_role

  # creatable_by?(user) can use methods like...
  include Authority::Abilities

  # can_create?(resource) can use methods like...
  include Authority::UserAbilities
  # privileges, refer to: /app/authorizers/user_authorizer.rb
  # self.authorizer_name = 'UserAuthorizer'
  # described in the model which you want to apply the role
  resourcify

  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # belongs_to :roles
  def assign_default_role
    self.add_role(:client)
  end
end