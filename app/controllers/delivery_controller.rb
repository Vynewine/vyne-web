class DeliveryController < ApplicationController
  include CoordinateHelper

  before_action :authenticate_user!
  authorize_actions_for UserAuthorizer
  authority_actions :get_courier_location => 'read'

  def get_courier_location
    if current_user.admin?
      order = Order.find_by(id: params[:id])
    else
      order = Order.find_by(id: params[:id], client_id: current_user)
    end

    if order.blank?
      render json: ['404'], status: :not_found
      return
    else

      Rails.logger.info 'Client ' + current_user.email + ' Requested map update for order: ' + order.id.to_s

      key = 'order:' + order.id.to_s + ':courier_location'

      DataCache.data.multi do
        DataCache.set(key, Time.now.strftime('%F %T'))
        DataCache.data.expire(key, 30)
      end

      result = {
          :errors => [],
          :data => {
              :name => '',
              :lat => 0,
              :lng => 0
          }
      }

      unless order.delivery_courier.blank?
        unless order.delivery_courier['lat'].blank? || order.delivery_courier['lng'].blank?
          result[:data][:lat] = order.delivery_courier['lat']
          result[:data][:lng] = order.delivery_courier['lng']
        end

        unless order.delivery_courier['name'].blank?
          result[:data][:name] = order.delivery_courier['name']
        end
      end

      render json: result

    end
  end
end