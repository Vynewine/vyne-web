class User < ActiveRecord::Base

  has_many :orders
  has_many :payments

  has_and_belongs_to_many :addresses
  accepts_nested_attributes_for :addresses, :reject_if => :all_blank, :allow_destroy => true
  
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
  validates :name, :email, :mobile, :presence => true
  # belongs_to :roles
  def assign_default_role
    # puts "assigning"
    # self.add_role(:client)
  end
end