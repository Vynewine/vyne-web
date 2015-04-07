module PromotionHelper

  @logger = Logging.logger['PromotionHelper']

  def self.calculate_order_item_price(order_item)
    if order_item.user_promotion.blank?
      order_item.price
    else
      if order_item.user_promotion.promotion_code.promotion.extra_bottle
        0
      elsif order_item.user_promotion.promotion_code.promotion.free_bottle_category != nil &&
          order_item.category == order_item.user_promotion.promotion_code.promotion.free_bottle_category
        0
      else
        order_item.price
      end
    end
  end

  def self.add_promotion(user, code)

    log "Applying promotion for user: #{user.id} and code: #{code}"

    begin

      promo_code = PromotionCode.find_by(:code => code, :active => true)

      if promo_code.blank?
        message = "Promo code #{code} not found"
        log_error message
        return [message]
      end

      unless promo_code.restrictions.blank?
        message = promo_code.restrictions.join(' ')
        log_error message
        return [message]
      end

      user_promotion = UserPromotion.new(
          user: user,
          redeemed: false,
          can_be_redeemed: true,
          promotion_code: promo_code
      )

      unless user_promotion.save
        log_error ["Can't save user promotion for user #{user.id}"] + user_promotion.errors.full_messages
        return user_promotion.errors.full_messages
      end

      if promo_code.referral_code?

        log "Creating referral for user #{promo_code.user.id}"

        referral = Referral.new(
            existing_user: promo_code.user,
            referred_user: user,
            promotion_code: promo_code
        )

        unless referral.save
          log_error ["Can't save referral for user #{user.id}"] + referral.errors.full_messages
          return referral.errors.full_messages
        end

        user_promotion = UserPromotion.new(
            user: promo_code.user,
            redeemed: false,
            can_be_redeemed: false,
            promotion_code: promo_code,
            referral: referral
        )

        unless user_promotion.save
          log_error ["Can't save user promotion for user #{user_promotion.user.id}"] + user_promotion.errors.full_messages
          return user_promotion.errors.full_messages
        end
      end

      promo_code.redeem_count += 1

      unless promo_code.save
        log_error ["Can't save promotion code"] + promo_code.errors.full_messages
        return promo_code.errors.full_messages
      end

    rescue Exception => exception
      message = "Error occurred while applying promotion: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
    end

  end

  def self.enable_referral_promotion(user)
    log "Enabling referral promotion for user: #{user.id}."
    begin

      referral_promotion = Promotion.where(
          :active => true,
          :referral_promotion => true
      ).first

      if referral_promotion.blank?
        log_error 'No active referral promotion found'
        return
      end

      promotion_codes = PromotionCode.new(
          :promotion => referral_promotion,
          :category => PromotionCode.categories[:referral_code],
          :user => user,
          :active => true
      )

      unless promotion_codes.save
        log_error promotion_codes.errors.full_messages
        return promotion_codes.errors.full_messages
      end

    rescue Exception => exception
      message = "Error occurred while enabling referral promotion: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
    end

  end

  def self.apply_promotion(order)

    log "Applying promotion for order #{order.id}"

    begin
      user_promotion = UserPromotion
                           .where(:user => order.client, :can_be_redeemed => true, :redeemed => false)
                           .order('id DESC').first

      unless user_promotion.blank?

        # Different logic for different promotion will go here in the future
        if user_promotion.promotion_code.promotion.extra_bottle
          order.order_items.new({
                                    :quantity => 1,
                                    :user_promotion => user_promotion
                                })
        elsif user_promotion.promotion_code.promotion.free_bottle_category != nil

          item = order.order_items.select { |item| item.category ==
              user_promotion.promotion_code.promotion.free_bottle_category }.first

          unless item.blank?
            item.user_promotion = user_promotion
            unless item.save
              log_error ['Error while applying user promotion'] + item.errors.full_messages
            end
          end

        end

        user_promotion.redeemed = true

        unless user_promotion.save
          log_error ['Error while applying user promotion'] + user_promotion.errors.full_messages
        end
      end
    rescue Exception => exception
      message = "Error occurred while applying promotion: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
    end
  end

  def self.process_sharing_reward(user_promotion)

    log "Processing sharing reward for user promotion id: #{user_promotion.id}"

    begin

      referral = Referral.find_by(
          referred_user_id: user_promotion.user,
          promotion_code: user_promotion.promotion_code
      )

      unless referral.blank?
        referral_user_promotion = UserPromotion.find_by(referral: referral)

        if referral_user_promotion.blank?
          log_error "User Promotion for referral id: #{referral.id} not found."
        else
          referral_user_promotion.can_be_redeemed = true
          unless referral_user_promotion.save
            log_error referral_user_promotion.errors.full_messages
          end
        end
      end

    rescue Exception => exception
      message = "Error occurred while process_sharing_reward: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
    end

  end

  def self.get_promotion_info(user, promo_code, warehouse)

    promotion = nil
    promo_info = {
        title: '',
        description: '',
        free_delivery: false,
        extra_bottle: false,
        free_bottle_category: '',
        new_accounts_only: true,
        errors: []
    }

    if user.blank?
      unless promo_code.blank?
        promo_code = PromotionCode.find_by(code: promo_code, active: true)
        unless promo_code.blank?
          promotion = promo_code.promotion
        end
      end
    else
      user_promotion = UserPromotion.find_by(:user => user, :can_be_redeemed => true, :redeemed => false)
      unless user_promotion.blank?
        promotion = user_promotion.promotion_code.promotion
      end
    end

    unless promotion.blank?

      promo_info[:title] = promotion.title
      promo_info[:description] = promotion.description
      promo_info[:free_delivery] = promotion.free_delivery
      promo_info[:extra_bottle] = promotion.extra_bottle
      promo_info[:free_bottle_category] = promotion.free_bottle_category.blank? ? '' : promotion.free_bottle_category.id
      promo_info[:new_accounts_only] = promotion.new_accounts_only

      unless warehouse.blank?

        warehouse_promotion = WarehousePromotion.find_by(
            :warehouse => warehouse,
            :promotion => promotion,
            :active => true
        )

        if warehouse_promotion.blank?
          promo_info[:errors] = ["We're sorry but looks like Merchant in your area in not taking part in '#{promotion.title}' promotion at the moment"]
        end
      end
    end

    promo_info
  end

  def self.is_free_promotion(order)

    log "Checking if free promotion is available for the order #{order.id}"

    begin

      user_promotion = UserPromotion
                           .where(:user => order.client, :can_be_redeemed => true, :redeemed => false)
                           .order('id DESC').first

      if user_promotion.blank?
        return false
      else

        is_free = false

        promotion = user_promotion.promotion_code.promotion

        unless promotion.free_bottle_category.blank?
          if order.order_items.length == 1 && order.order_items[0].category == promotion.free_bottle_category
            if promotion.free_delivery
              is_free = true
            end
          end
        end

        log "User promotion #{user_promotion.id} is free: #{is_free}"

        return is_free
      end

    rescue Exception => exception
      message = "Error occurred while process_sharing_reward: #{exception.class} - #{exception.message}"
      log_error message
      log_error exception
    end
  end

  def self.log(message)
    @logger.info message
  end

  def self.log_error(message)
    @logger.error message
  end

end