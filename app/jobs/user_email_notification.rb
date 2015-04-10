class UserEmailNotification
  @queue = :user_email_notifications

  @logger = Logging.logger['UserEmailNotification']

  def self.perform (user_id, notification_name)
    log "Processing email notification job: #{notification_name} - for user id: #{user_id.to_s}"
    user = User.find(user_id)
    UserMailer.send(notification_name, user)
  end

  def self.log(message)
    @logger.info message
  end
end