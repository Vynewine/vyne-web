class DataCache

  ADMIN_NOTIFICATION_CHANNEL = 'admin-notifications'

  def self.data
    @data ||= Redis.new(:url => Rails.application.config.redis)
  end

  def self.set(key, value)
    data.set(key, value)
  end

  def self.get(key)
    data.get(key)
  end

  def self.get_i(key)
    data.get(key).to_i
  end
end