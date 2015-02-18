class OrderFulfilment
  @queue = :order_fulfilment

  def self.perform (order_id)
    #Set order to pending status.
    #Send merchant notification
  end
end