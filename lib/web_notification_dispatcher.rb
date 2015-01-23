require 'redis'
require 'json'
require 'erb'

module WebNotificationDispatcher

  @logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  TAG = 'Web Notification Dispatcher'

  def self.publish(warehouse_ids, notification)
    log "Dispatching message: '#{notification}' to warehouse #{warehouse_ids}"
    DataCache.data.publish(DataCache::ADMIN_NOTIFICATION_CHANNEL, sanitize({warehouses: warehouse_ids, text: notification}))
  end

  private

  def self.sanitize(message)
    message.each { |key, value| message[key] = ERB::Util.html_escape(value) }
    JSON.generate(message)
  end

  def self.log(message)
    @logger.tagged(TAG) { @logger.info message }
  end
end