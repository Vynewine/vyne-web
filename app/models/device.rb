class Device < ActiveRecord::Base
  acts_as_paranoid
  has_and_belongs_to_many :warehouses, :join_table => :devices_warehouses

  def self.generate_key
    rand(36**8).to_s(36)
  end
end