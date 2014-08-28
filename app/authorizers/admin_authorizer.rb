# Other authorizers should subclass this one
class AdminAuthorizer < ApplicationAuthorizer

  def self.updatable_by?(user)
    user.has_role?(:superadmin)
  end

  def self.creatable_by?(user)
    user.has_role?(:superadmin)
  end

  def self.readable_by?(user)
    user.has_role?(:superadmin)
  end

  def self.deletable_by?(user)
    user.has_role?(:superadmin)
  end

end