class OrderItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :order
  belongs_to :wine
  belongs_to :occasion
  belongs_to :type
  belongs_to :category
  has_many :food_items

  def preferences
    preferences = []

    if food_items.blank?
      unless occasion.blank?
        preferences << occasion.name
      end

      unless type.blank?
        preferences << type.name
      end

      unless specific_wine.blank?
        preferences << specific_wine
      end
    else
      food_items.each do |item|

        unless item.food.blank?
          food = item.food.name
          unless item.preparation.blank?
            food += ' (' + item.preparation.name + ')'
          end
          preferences << food
        end
      end
    end

    preferences
  end
end