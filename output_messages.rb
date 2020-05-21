# frozen_string_literal: true

module OutputMessages
  NO_PRODUCTS_LEFT = 'Sorry, but no products left, try it another time:('
  GREETING = 'Hi! Welcome to vending machine!'
  AVAILABLE_PRODUCTS = 'Chose one of the available products:'
  NO_SUCH_PRODUCT = 'We cannot provide you with product you chose, try again!'
  TROW_COIN = 'Please trow coin to the machine.'
  NOT_ENOUGH_CHANGE = 'Sorry to say, but we cannot provide you with change, take your money back.'
  TAKE_PRODUCT = 'Product sold, take it!'
  TAKE_CHANGE = "Take your change, it's there!"

  class << self
    def available_products(products, prices)
      product_messages = products.map { |product, amount| "#{product}: #{prices[product]}$, #{amount} items available" }

      return AVAILABLE_PRODUCTS, *product_messages
    end

    def price(product, price)
      "You selected #{product}, it costs #{price}$, waiting for your money:)"
    end

    def not_enough_money(coin, amount_left)
      "You put #{coin}, #{amount_left} left."
    end

    def coin_not_acceptable(coin)
      "Coin you put (#{coin}) cannot be accepted, take it back."
    end

    def supported_coins(supported_coins)
      "Coins we can accept:
       #{supported_coins}"
    end

    def take_change(change)
      return if change.empty?

      return TAKE_CHANGE, *change
    end
  end
end
