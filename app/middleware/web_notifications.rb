require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'

class WebNotifications
  KEEPALIVE_TIME = 15 # in seconds
  TAG = '[Web Notifications]'

  def initialize(app)
    @app = app
    @clients = []
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME})
      ws.on :open do |event|
        puts "#{TAG} web socket open #{ws.object_id}"

        if @clients.blank?
          subscribe_to_redis
        end

        # User gets a cookie "warehouses" set at a login.
        # Messages are dispatched to users based on their warehouses relationship.
        req = Rack::Request.new(env)
        warehouses = []
        unless req.cookies['warehouses'].blank?
          warehouses = req.cookies['warehouses'] ? req.cookies['warehouses'].split(',') : []
        end
        client = {
            :warehouses => warehouses,
            :websocket => ws
        }

        @clients << client
      end

      ws.on :message do |event|
        puts "#{TAG} web socket message #{event.data.to_s}"
        DataCache.data.publish(DataCache::ADMIN_NOTIFICATION_CHANNEL, sanitize(event.data))
      end

      ws.on :close do |event|
        puts "#{TAG} web socket closed. object_id: #{ws.object_id}, code: #{event.code}, reason: #{event.reason}"
        @clients.delete(ws)
        ws = nil
      end

      # Return async Rack response
      ws.rack_response

    else
      @app.call(env)
    end
  end

  private

  def subscribe_to_redis
    puts "#{TAG} redis subscribe"
    url = Rails.application.config.redis
    unless url.blank?
      uri = URI.parse(url)
      Thread.new do
        redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        redis_sub.subscribe(DataCache::ADMIN_NOTIFICATION_CHANNEL) do |on|
          on.message do |channel, msg|
            puts "#{TAG} clients count #{@clients.length}"
            puts "#{TAG} redis message #{msg}"
            message = JSON.parse(msg)
            @clients.each do |client|
              if client[:warehouses][0] == 'admin'
                client[:websocket].send(msg)
              else
                unless (client[:warehouses] & message['warehouses']).empty?
                  client[:websocket].send(msg)
                end
              end
            end
          end
        end
      end
    end
  end

  def sanitize(message)
    json = JSON.parse(message)
    json.each { |key, value| json[key] = ERB::Util.html_escape(value) }
    JSON.generate(json)
  end

end
