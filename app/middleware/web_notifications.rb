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
    @subscribed = false
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME})
      ws.on :open do |event|
        puts "#{TAG} web socket open #{ws.object_id}"

        unless @subscribed
          subscribe_to_redis
        end

        # User gets a cookie "warehouses" set at a login.
        # Messages are dispatched to users based on their warehouses relationship.
        req = Rack::Request.new(env)
        warehouses = []

        unless req.cookies['warehouses'].blank?
          warehouses = req.cookies['warehouses'].split(',')
        end

        unless warehouses.blank?
          client = {
              :warehouses => warehouses,
              :websocket => ws,
              :id => ws.object_id
          }

          @clients << client
        end
      end

      ws.on :message do |event|
        puts "#{TAG} web socket message #{event.data.to_s}"
        DataCache.data.publish(DataCache::ADMIN_NOTIFICATION_CHANNEL, sanitize(event.data))
      end

      ws.on :close do |event|
        puts "#{TAG} web socket closed. object_id: #{ws.object_id}, code: #{event.code}, reason: #{event.reason}"
        @clients.delete_if { |client| client[:id] == ws.object_id }
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
    @subscribed = true
    puts "#{TAG} redis subscribe"
    url = Rails.application.config.redis
    unless url.blank?
      uri = URI.parse(url)
      Thread.new do
        begin
          redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
          redis_sub.subscribe(DataCache::ADMIN_NOTIFICATION_CHANNEL) do |on|
            on.message do |channel, msg|
              puts "#{TAG} clients count #{@clients.length}"
              puts "#{TAG} redis message #{msg}"
              message = JSON.parse(msg)
              @clients.each do |client|
                if message['recipients'].blank?
                  if client[:warehouses][0] == 'admin'
                    client[:websocket].send(msg)
                  else
                    unless ((client[:warehouses].map { |w| w.to_i }) & (message['warehouses'].split(',').map { |w| w.to_i })).empty?
                      client[:websocket].send(msg)
                    end
                  end
                else
                  if client[:warehouses][0] == message['recipients']
                    client[:websocket].send(msg)
                  end
                end

              end
            end
          end
        rescue Exception => exception
          puts "#{TAG} ERROR Exception from Redis Subscriber #{exception.class} - #{exception.message}"
          puts "#{TAG} #{exception.backtrace}"
          @subscribed = false
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
