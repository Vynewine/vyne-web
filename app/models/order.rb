class Order < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :status
  belongs_to :address
  belongs_to :warehouse
  belongs_to :payment
  belongs_to :client, class_name: "User"
  belongs_to :advisor, class_name: "User"
  has_many :order_items

  accepts_nested_attributes_for :address, :reject_if => :all_blank, :allow_destroy => true

  scope :user_id, ->(id) { where("client_id = ?", id) }

  enum delivery_type: {google_coordinate: 'google_coordinate', shutl: 'shutl'}

  before_save :calculate_delivery_price

  self.per_page = 15

  def total_price
    if (order_items.map { |item| item.price }).include?(nil)
      nil
    else
      total = (order_items.map { |item| item.final_price }).inject(:+)
      total + (delivery_price.blank? ? 0 : delivery_price)
    end
  end

  def estimated_total_min_price
    all_prices = order_items.map do |item|
      item_price = 0
      unless item.category.blank?
        item_price = item.category.price_min
        unless item.user_promotion.blank?
          unless item.user_promotion.promotion_code.promotion.free_bottle_category.blank?
            if item.category == item.user_promotion.promotion_code.promotion.free_bottle_category
              item_price = 0
            end
          end
        end
      end
      item_price
    end

    total = all_prices.inject(:+)
    total + (delivery_price.blank? ? 0 : delivery_price)
  end

  def estimated_total_max_price
    all_prices = order_items.map do |item|
      item_price = 0
      unless item.category.blank?
        item_price = item.category.price_max
        unless item.user_promotion.blank?
          unless item.user_promotion.promotion_code.promotion.free_bottle_category.blank?
            if item.category == item.user_promotion.promotion_code.promotion.free_bottle_category
              item_price = 0
            end
          end
        end
      end
      item_price
    end

    total = all_prices.inject(:+)
    total + (delivery_price.blank? ? 0 : delivery_price)
  end

  def total_wine_cost
    if (order_items.map { |item| item.cost }).include?(nil)
      nil
    else
      (order_items.map { |item| item.cost }).inject(:+)
    end
  end

  def delivery_status_json
    delivery_status.to_json
  end

  def advisory_complete
    if order_items.blank?
      return false
    else
      if order_items.select { |item| item.wine.blank? }.count > 0
        return false
      else
        return true
      end
    end
  end

  def can_be_advised
    [Status.statuses[:pending], Status.statuses[:packing], Status.statuses[:advised]].include? status.id
  end

  def can_request_substitution?
    if order_items.blank? || status_id != Status.statuses[:advised]
      false
    else
      if order_items.select { |item| item.substitution_status != 'not_requested' }.count > 0
        false
      else
        true
      end
    end
  end

  def order_change_timeout_seconds
    if advisory_completed_at.blank? || status_id != Status.statuses[:advised]
      0
    else
      time_out = Time.now.utc - 5.minutes
      if advisory_completed_at > time_out
        return (advisory_completed_at - time_out).seconds.to_i
      else
        0
      end
    end
  end

  def substitution_requested?
    if order_items.blank?
      false
    else
      if order_items.select { |item| item.substitution_status.requested? }.count > 0
        true
      else
        false
      end
    end
  end

  def order_schedule
    unless information.blank? || information['slot_date'].blank?
      {
          from: Time.parse(information['slot_date'] + ' ' + information['slot_from']),
          to: Time.parse(information['slot_date'] + ' ' + information['slot_to']),
          schedule_date: information['schedule_date'].blank? ? '' : Time.parse(information['schedule_date'])
      }
    end
  end

  def calculate_delivery_price

    # Check for free delivery promotion
    promotion_items = order_items.select { |item| !item.user_promotion.blank? }

    promotion_items.each do |item|
      if item.user_promotion.promotion_code.promotion.free_delivery
        self.delivery_price = 0
        return
      end
    end

    # Delivery price for one house wine £3.5 otherwise £2.5
    wines = order_items.select { |item| item.user_promotion.blank? }

    if wines.count == 1 && wines[0].category_id == 1
      self.delivery_price = 3.5
    else
      self.delivery_price = 2.5
    end
  end

  def self.actionable_order_counts(warehouses, is_admin)

    counts = {
        :pending => 0,
        :packing => 0,
        :advised => 0,
        :in_transit => 0,
        :pickup => 0,
        :payment_failed => 0,
        :created => 0
    }

    unless warehouses.blank? && !is_admin

      statuses_to_report = [
          Status.statuses[:pending],
          Status.statuses[:packing],
          Status.statuses[:advised],
          Status.statuses[:in_transit],
          Status.statuses[:pickup],
          Status.statuses[:payment_failed],
          Status.statuses[:created]
      ]

      if is_admin
        actionable_orders = where(:status => statuses_to_report)
      else
        actionable_orders = where(:status => statuses_to_report, :warehouse => warehouses)
      end

      actionable_orders.each do |order|
        case order.status_id
          when Status.statuses[:pending]
            counts[:pending] += 1
          when Status.statuses[:packing]
            counts[:packing] += 1
          when Status.statuses[:advised]
            counts[:advised] += 1
          when Status.statuses[:in_transit]
            counts[:in_transit] += 1
          when Status.statuses[:pickup]
            counts[:pickup] += 1
          when Status.statuses[:payment_failed]
            counts[:payment_failed] += 1
          when Status.statuses[:created]
            counts[:created] += 1
        end
      end
    end
    counts
  end

end
