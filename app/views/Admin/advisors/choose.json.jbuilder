json.array!(@quotes['quote_collection']['quotes']) do |quote|
				  # json.quote quote
                    json.id quote['id'] # "543b9b2ce4b0ea21b573dbf4-1413193392"
                 json.price "%.2f" % (quote['customer_price']/100) # 1074
 # json.customer_price_ex_tax quote['customer_price_ex_tax'] # 895
              json.delivery Time.parse(quote['delivery_finish']).strftime("%d/%m/%Y - %H:%M") # "2014-10-13T13 #00+01 #00"
        # json.delivery_start quote['delivery_start'] # "2014-10-13T12 #00+01 #00"
        # json.merchant_price quote['merchant_price'] # 895
         # json.pickup_finish quote['pickup_finish'] # "2014-10-13T12 #00+01 #00"
          # json.pickup_start quote['pickup_start'] # "2014-10-13T10 #45+01 #00"
           json.valid_until Time.parse(quote['valid_until']).strftime("%d/%m/%Y - %H:%M") # "2014-10-13T10 #45+01 #00"
               json.vehicle quote['vehicle'] # "motorbike"
end
