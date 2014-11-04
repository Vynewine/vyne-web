require 'mandrill'

module UserMailer
  def first_time_ordered(order)

    begin

      price = order.order_items[0].price.to_s
      wine_1_order = order.order_items[0].category.name + ' wine (£' + price + ')'

      pref_1_wine1 = nil
      pref_2_wine1 = nil
      pref_3_wine1 = nil

      pref_1_wine2 = nil
      pref_2_wine2 = nil
      pref_3_wine2 = nil

      #If paired with food
      foods_1 = order.order_items[0].food_items
      if foods_1.blank?
        if order.order_items[0].specific_wine.blank? && !order.order_items[0].occasion.blank?
          #If paired with occastion
          pref_1_wine1 = order.order_items[0].occasion.name
          pref_2_wine1 = order.order_items[0].type.name
        else
          pref_1_wine1 = order.order_items[0].specific_wine
        end
      else
        unless foods_1[0].blank?
          pref_1_wine1 = foods_1[0].food.name
          unless foods_1[0].preparation.blank?
            pref_1_wine1 += ' (' + foods_1[0].preparation.name + ')'
          end
        end
        unless foods_1[1].blank?
          pref_2_wine1 = foods_1[1].food.name
          unless foods_1[1].preparation.blank?
            pref_2_wine1 += ' (' + foods_1[1].preparation.name + ')'
          end
        end

        unless foods_1[2].blank?
          pref_3_wine1 = foods_1[2].food.name
          unless foods_1[2].preparation.blank?
            pref_3_wine1 += ' (' + foods_1[2].preparation.name + ')'
          end
        end
      end

      unless order.order_items[1].blank?

        wine_2_order = order.order_items[1].category.name + ' wine (£' + order.order_items[1].price.to_s + ')'

        foods_2 = order.order_items[1].food_items
        if foods_2.blank?
          if order.order_items[0].specific_wine.blank? && !order.order_items[0].occasion.blank?
            #If paired with occastion
            pref_1_wine2 = order.order_items[0].occasion.name
            pref_2_wine2 = order.order_items[0].type.name
          else
            pref_1_wine2 = order.order_items[0].specific_wine
          end
        else

          unless foods_2[0].blank?
            pref_1_wine2 = foods_2[0].food.name
            unless foods_2[0].preparation.blank?
              pref_1_wine2 += ' (' + foods_2[0].preparation.name + ')'
            end
          end
          unless foods_2[1].blank?
            pref_2_wine2 = foods_2[1].food.name
            unless foods_2[1].preparation.blank?
              pref_2_wine2 += ' (' + foods_2[1].preparation.name + ')'
            end
          end

          unless foods_2[2].blank?
            pref_3_wine2 = foods_2[2].food.name
            unless foods_2[2].preparation.blank?
              pref_3_wine2 += ' (' + foods_2[2].preparation.name + ')'
            end
          end
        end
      end

      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'orderplaced-1tochv1'
      message = {
          :subject => 'Order Placed with Vyne',
          :from_email => 'checkout@vyne.london',
          :from_name => 'Vyne Checkout',
          :to => [
              {
                  :email => order.client.email,
                  :name => order.client.first_name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => order.client.email,
                  :vars => [
                      {
                          :name => 'FIRSTNAME',
                          :content => order.client.first_name
                      },
                      {
                          :name => 'WINEORDER1',
                          :content => wine_1_order

                      },
                      {
                          :name => 'ADDRESSLINE1',
                          :content => order.address.street
                      },
                      {
                          :name => 'POSTCODE',
                          :content => order.address.postcode
                      }
                  ]
              }
          ]

      }



      unless pref_1_wine1.blank?
        message[:merge_vars][0][:vars] << { :name => 'PREF1WINE1', :content => pref_1_wine1 }
      end
      unless pref_2_wine1.blank?
        message[:merge_vars][0][:vars] << { :name => 'PREF2WINE1', :content => pref_2_wine1 }
      end
      unless pref_3_wine1.blank?
        message[:merge_vars][0][:vars] << { :name => 'PREF3WINE1', :content => pref_3_wine1 }
      end

      unless pref_1_wine2.blank?
        message[:merge_vars][0][:vars] <<  { :name => 'WINEORDER2', :content => wine_2_order }

        message[:merge_vars][0][:vars] << { :name => 'PREF1WINE2', :content => pref_1_wine2 }
      end
      unless pref_2_wine2.blank?
        message[:merge_vars][0][:vars] << { :name => 'PREF2WINE2', :content => pref_2_wine2 }
      end
      unless pref_3_wine2.blank?
        message[:merge_vars][0][:vars] << { :name => 'PREF3WINE2', :content => pref_3_wine2 }
      end

      puts json: message

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error => e

      # Mandrill errors are thrown as exceptions
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
        #TODO: This needs to go to Sentry!!!

    rescue Mandrill::Error, Excon::Errors::SocketError => e
      # Mandrill errors are thrown as exceptions
      message = "A mandrill error occurred: #{e.class} - #{e.message} - for user: #{order.client.email}"
      puts message
      Rails.logger.error message
      #raise - probably don't want to raise if third party service is down.
    end
  end

  def order_confirmation(order)

    begin
      mandrill = Mandrill::API.new Rails.application.config.mandrill
      template_name = 'orderplaced-1tochv1'
      message = {
          :to => [
              {
                  :email => order.client.email,
                  :name => order.client.name
              }
          ],
          :merge_vars => [
              {
                  :rcpt => order.client.email,
                  :vars => [
                      {
                          :name => 'NAME',
                          :content => order.client.name
                      }
                  ]
              }
          ]

      }

      mandrill.messages.send_template template_name, nil, message

    rescue Mandrill::Error, Excon::Errors::SocketError => e
      # Mandrill errors are thrown as exceptions
      message = "A mandrill error occurred: #{e.class} - #{e.message} - for user: #{order.client.email}"
      puts message
      Rails.logger.error message
      #raise - probably don't want to raise if third party service is down.
    end
  end
end