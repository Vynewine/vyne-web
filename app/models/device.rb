class Device < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :warehouse

  def self.generate_key
    rand(36**8).to_s(36)
  end
end