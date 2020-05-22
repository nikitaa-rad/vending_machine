require_relative 'output_messages'

class MachineMaintainer
  INITIAL_CASHBOX = {
    '5' => 1,
    '2' => 1,
    '1' => 1,
    '0.5' => 1,
    '0.25' => 1
  }.freeze
  INITIAL_PRODUCTS = {
    'cola' => 4,
    'sprite' => 3,
    'fanta' => 1,
    'snickers' => 7
  }.freeze
  PRICES = {
    'cola' => 2,
    'sprite' => 3,
    'fanta' => 1.75,
    'snickers' => 1.25
  }.freeze
  SUPPORTED_COINS = %w(5, 2, 1, 0.5, 0.25).freeze

  attr_reader :cashbox, :products, :selected_product, :cash_buffer

  def initialize
    @cashbox = INITIAL_CASHBOX.dup
    @products = INITIAL_PRODUCTS.dup
    @cash_buffer = {}
    @selected_product = nil
    @change = []
  end

  def available_products
    raise OutputMessages::NO_PRODUCTS_LEFT if products.empty?

    products
  end

  def set_selected_product(selected_product)
    raise ArgumentError, OutputMessages::NO_SUCH_PRODUCT unless products.keys.include? selected_product

    @selected_product = selected_product
  end

  def price
    PRICES[selected_product]
  end

  def add_more?
    money_in_buffer < price
  end

  def left_to_buy
    price - money_in_buffer
  end

  def add_to_buffer(coin)
    raise ArgumentError, OutputMessages.coin_not_acceptable(coin) unless SUPPORTED_COINS.include? coin

    @cash_buffer[coin] = (cash_buffer[coin] || 0) + 1
  end

  def sell
    @available_coins = all_available_coins

    left_for_change = money_in_buffer - price

    @change = []

    left_for_change = set_change left_for_change

    if left_for_change.positive?
      raise OutputMessages::NOT_ENOUGH_CHANGE
    end

    reduce_product

    update_cashbox

    clear_buffers

    @change.flatten
  end

  private

  def money_in_buffer
    cash_buffer.sum { |key, amount| key.to_f * amount }
  end

  def all_available_coins
    cashbox.merge(cash_buffer) { |key, old, new| old + new }
      .sort_by { |key, amount| key.to_f * -1 }
      .to_h
  end

  def reduce_coin(coin, amount)
    @available_coins[coin] -= amount

    @available_coins.delete coin if @available_coins[coin] == 0

    [coin] * amount
  end

  def set_change(left_for_change)
    @available_coins.each do |cashbox_coin, amount|
      next if left_for_change < cashbox_coin.to_f

      reduce_amount = if cashbox_coin.to_f * amount > left_for_change
                        (left_for_change / cashbox_coin.to_f).to_i
                      else
                        amount
                      end

      left_for_change = left_for_change - (cashbox_coin.to_f * reduce_amount)

      @change << reduce_coin(cashbox_coin, reduce_amount)

      next
    end

    left_for_change
  end

  def reduce_product
    @products[selected_product] -= 1

    @products.delete selected_product if products[selected_product] == 0
  end

  def update_cashbox
    @cashbox = @available_coins
  end

  def clear_buffers
    @cash_buffer = {}
    @selected_product = nil
  end
end
