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

  self.per_page = 15

  def total_price
    if (order_items.map { |item| item.price }).include?(nil)
      nil
    else
      (order_items.map { |item| item.price }).inject(:+)
    end
  end

  def total_wine_cost
    if (order_items.map { |item| item.cost }).include?(nil)
      nil
    else
      (order_items.map { |item| item.cost }).inject(:+)
    end
  end

  def total_cost
    cost = total_wine_cost
    if cost.blank? || delivery_cost.blank?
      nil
    else
      cost += delivery_cost
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
    if order_items.blank?
      false
    else
      if order_items.select { |item| item.substitution_status != 'not_requested' }.count > 0
        false
      else
        true
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

end
