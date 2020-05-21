require_relative 'output_messages'
require_relative 'machine_maintainer'

class VendingMachine
  attr_reader :machine_maintainer

  def self.run(*args)
    new(*args).run
  end

  def initialize
    @machine_maintainer = MachineMaintainer.new
  end

  def run
    loop do
      puts OutputMessages::GREETING

      begin
        show_products
      rescue RuntimeError => e
        puts e.message
        break
      end

      puts OutputMessages.supported_coins MachineMaintainer::SUPPORTED_COINS

      selected_product = gets.strip
      begin
        machine_maintainer.set_selected_product selected_product
      rescue ArgumentError => e
        puts e.message
        next
      end

      show_price selected_product

      take_cash

      sell_product
    end
  end

  private

  def show_products
    puts OutputMessages.available_products(machine_maintainer.available_products, MachineMaintainer::PRICES)
  end

  def show_price(selected_product)
    price = machine_maintainer.price

    puts OutputMessages.price(selected_product, price)
  end

  def take_cash
    while machine_maintainer.add_more?
      puts OutputMessages::TROW_COIN

      coin = gets.strip
      begin
        machine_maintainer.add_to_buffer coin
      rescue ArgumentError => e
        puts e.message
        puts OutputMessages.supported_coins MachineMaintainer::SUPPORTED_COINS

        next
      end

      puts OutputMessages.not_enough_money(coin, machine_maintainer.left_to_buy) if machine_maintainer.add_more?
    end
  end

  def sell_product
    change = machine_maintainer.sell

    puts OutputMessages::TAKE_PRODUCT
    puts OutputMessages.take_change change
  rescue RuntimeError => e
    puts e.message
  end
end

VendingMachine.run
