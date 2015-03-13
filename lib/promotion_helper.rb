module PromotionHelper

  @logger = Logging.logger['PromotionHelper']

  def self.calculate_order_item_price(order_item, user_promotion)
    if user_promotion.blank?
      order_item.price
    else
      if user_promotion.referral_code.referral.promotion.wine?
        0
      else
        order_item.price
      end
    end
  end

  def self.apply_sign_up_promotion(user, code)

    log "Applying promotions for user: #{user.id} and code: #{code}"

    begin
      referral_code = ReferralCode.find_by(code: code)

      if referral_code.blank?
        message = 'Referral code not found'
        log_error message
        return [message]
      end

      UserPromotion.new_account_reward(referral_code, user)

      new_referral = Referral.new(
          :user => user,
          :promotion => referral_code.referral.promotion
      )

      unless new_referral.save
        log_error new_referral.errors.full_messages
        return new_referral.errors.full_messages
      end

      new_referral_code = ReferralCode.new(
          :referral => new_referral
      )

      unless new_referral_code.save
        log_error new_referral_code.errors.full_messages
        return new_referral_code.errors.full_messages
      end

    rescue Exception => exception
      message = "Error occurred while applying promotions: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
    end
  end

  def self.enable_referral_promotion(user)
    log "Enabling referral promotion for user: #{user.id}."
    begin

      current_promotion = Promotion.where(:category => Promotion.categories[:wine], :active => true).first

      if current_promotion.blank?
        log_error 'No active promotions found'
        return
      end

      new_referral = Referral.new(
          :user => user,
          :promotion => current_promotion
      )

      unless new_referral.save
        log_error new_referral.errors.full_messages
        return new_referral.errors.full_messages
      end

      new_referral_code = ReferralCode.new(
          :referral => new_referral
      )

      unless new_referral_code.save
        log_error new_referral_code.errors.full_messages
        return new_referral_code.errors.full_messages
      end

    rescue Exception => exception
      message = "Error occurred while enabling referral promotion: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
    end

  end

  def self.process_sharing_reward(order_item)

    log "Processing sharing reward for order: #{order_item.order.id} order item: #{order_item.id}"

    begin
      unless order_item.blank?
        sharing_user_promotion = UserPromotion.find_by(
            :friend => order_item.order.client,
            :user => order_item.user_promotion.referral_code.referral.user,
            :category => UserPromotion.categories[:sharing_reward]
        )

        if sharing_user_promotion.blank? && !order_item.user_promotion.referral_code.referral.user.admin?
          log_error 'We should process this promotion'
        else
          sharing_user_promotion.can_be_redeemed = true
          sharing_user_promotion.save
        end
      end
    rescue Exception => exception
      message = "Error occurred while process_sharing_reward: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
    end

  end

  def self.get_promotion_text(user, promo_code, warehouse)

    promo = nil
    promo_text = ''

    if user.blank?
      unless promo_code.blank?
        referral_code = ReferralCode.find_by(code: promo_code)
        unless referral_code.blank?
          promo = referral_code.referral.promotion
        end
      end

    else
      user_promotion = UserPromotion.find_by(:user => user, :can_be_redeemed => true, :redeemed => false)
      unless user_promotion.blank?
        promo = user_promotion.referral_code.referral.promotion
      end
    end

    unless promo.blank?

      promo_text = promo.title

      unless warehouse.blank?

        warehouse_promotion = WarehousePromotion.find_by(
            :warehouse => warehouse,
            :promotion => promo,
            :active => true
        )

        if warehouse_promotion.blank?
          promo_text = "We're sorry but looks like Merchant in your area in not taking part in '#{promo.title}' promotion at the moment"
        end
      end
    end

    promo_text
  end

  def self.log(message)
    @logger.info message
  end

  def self.log_error(message)
    @logger.error message
  end

end