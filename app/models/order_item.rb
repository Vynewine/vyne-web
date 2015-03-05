class OrderItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :order
  belongs_to :wine
  belongs_to :occasion
  belongs_to :type
  belongs_to :category
  belongs_to :inventory
  belongs_to :user_promotion
  belongs_to :warehouse_promotion

  has_many :food_items

  enum substitution_status: %i(not_requested requested completed)

  def preferences
    preferences = []

    if food_items.blank?
      unless occasion.blank?
        preferences << 'Occasion: ' + occasion.name
      end

      unless type.blank?
        preferences << 'Wine Type: ' + type.name
      end

      unless specific_wine.blank?
        preferences << 'Specific Wine: ' + specific_wine
      end
    else

      food_items.each_with_index do |item, index|

        unless item.food.blank?
          food = item.food.name
          unless item.preparation.blank?
            food += ' (' + item.preparation.name + ')'
          end
          if index == 0
            preferences << 'Food: ' + food
          else
            preferences << food
          end

        end
      end
    end

    preferences
  end
end