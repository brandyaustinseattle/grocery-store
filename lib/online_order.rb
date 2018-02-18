require 'csv'
require 'awesome_print'
require 'money'
require_relative '../lib/order'
require_relative '../lib/customer'
I18n.enforce_available_locales = false

module Grocery
  class OnlineOrder < Order
    attr_reader :id, :products, :customer_id, :status

    def initialize(id, products, customer_id, status)
      super(id, products)
      @customer_id = customer_id
      @status = status
    end

    def total
      sum_with_tax_fee = super + Money.new(1000, "USD")
      # call .format on sum_with_tax_fee to format the instance of money
      return sum_with_tax_fee
    end

    def add_product(product_name, product_price, status)
      if @status == :pending || @status == :paid
        true_false = super(product_name, product_price)
        #true if product added, false if product not added
        return true_false
      end
      return nil
    end

    def self.all
      online_orders_entered = []
      CSV.read("/Users/brandyaustin/ada/week2/grocery_store/grocery-store/support/online_orders.csv").each do |row|
        id = row[0].to_i
        products = {}
        products_array = row[1].split(";")

        products_array.each do |item|
          name, price = item.split(':')
          products[name] = price.to_f
        end

        customer_id = row[2].to_i
        if row[3].nil?
          status = :pending
        else
          status = row[3].to_sym
        end
        online_orders_entered << OnlineOrder.new(id, products, customer_id, status)
      end
        return online_orders_entered
    end

    def self.find(id)
      super(id)
    end

    def self.find_by_customer(customer_id)
      online_orders_entered = self.all
      customers_online_orders = []
      online_orders_entered.each do |online_order|
        if online_orders.customer_id == customer_id
          customers_online_orders << online_order
        end
      return customers_online_orders  
    end

  end
end

test_order = Grocery::OnlineOrder.new(11, {"Pinto Beans"=>10.45, "Apples"=>8.01}, 4, :pending)

tots = test_order.total

puts tots
