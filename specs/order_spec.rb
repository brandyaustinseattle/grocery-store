require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/skip_dsl'
require_relative '../lib/order'

describe "Order Wave 1" do
  describe "#initialize" do
    it "Takes an ID and collection of products" do
      id = 1337
      order = Grocery::Order.new(id, {})

      order.must_respond_to :id
      order.id.must_equal id
      order.id.must_be_kind_of Integer

      order.must_respond_to :products
      order.products.length.must_equal 0
    end
  end

  describe "#total" do
    it "Returns the total from the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      sum = products.values.inject(0, :+)
      cents_total = (sum + (sum * 0.075))*100.round
      expected_total = Money.new(cents_total, "USD")

      order.total.must_equal expected_total
    end

    it "Returns a total of zero if there are no products" do
      order = Grocery::Order.new(1337, {})

      zero_with_money = Money.new(0, "USD")

      order.total.must_equal zero_with_money
    end
  end

  describe "#add_product" do
    it "Increases the number of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      before_count = products.count
      order = Grocery::Order.new(1337, products)

      order.add_product("salad", 4.25)
      expected_count = before_count + 1

      order.products.count.must_equal expected_count
    end

    it "Is added to the collection of products" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      order.add_product("sandwich", 4.25)

      order.products.include?("sandwich").must_equal true
    end

    it "Returns false if the product is already present" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      before_total = order.total
      result = order.add_product("banana", 4.25)
      after_total = order.total

      result.must_equal false
      before_total.must_equal after_total
    end

    it "Returns true if the product is new" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      result = order.add_product("salad", 4.25)

      result.must_equal true
    end
  end

  describe "#remove_product" do
    it "Removes the product from the list" do
      products = { "banana" => 1.99, "cracker" => 3.00 }
      order = Grocery::Order.new(1337, products)

      order.remove_product("banana")

      count = 0
      products.each do |single_order|
        count += 1
      end
      count.must_equal 1
    end
  end

  it "Returns true if the product was present and removed" do
    products = { "banana" => 1.99, "cracker" => 3.00 }
    order = Grocery::Order.new(1330, products)

    value = order.remove_product("banana")

    value.must_equal true
  end

  it "Returns false if the product was absent and not removed" do
    products = { "banana" => 1.99, "cracker" => 3.00 }
    order = Grocery::Order.new(1330, products)

    value = order.remove_product("pear")

    value.must_equal false
  end
end

describe "Order Wave 2" do
  describe "Order.all" do
    it "Returns an array of all orders" do
      orders_entered = Grocery::Order.all

      orders_entered.class.must_equal Array
      count = 0
      orders_entered.each do |order|
        count += 1
      end
      count.must_equal 100
    end

    it "Returns accurate information about the first order" do
      orders_entered = Grocery::Order.all

      first_order = orders_entered[0]

      first_order.id.must_equal 1
      first_order.products.must_equal({"Slivered Almonds"=>22.88, "Wholewheat flour"=>1.93, "Grape Seed Oil"=>74.9})
    end

    it "Returns accurate information about the last order" do
      orders_entered = Grocery::Order.all

      last_order = orders_entered[-1]

      last_order.id.must_equal 100
      last_order.products.must_equal({"Allspice"=>64.74, "Bran"=>14.72, "UnbleachedFlour"=>80.59})
    end
  end

  describe "Order.find" do
    it "Can find the first order from the CSV" do
      first_order = Grocery::Order.find(1)

      first_order.id.must_equal 1
      first_order.products.must_equal({"Slivered Almonds"=>22.88, "Wholewheat flour"=>1.93, "Grape Seed Oil"=>74.9})
    end

    it "Can find the last order from the CSV" do
      last_order = Grocery::Order.find(100)

      last_order.id.must_equal 100
      last_order.products.must_equal({"Allspice"=>64.74, "Bran"=>14.72, "UnbleachedFlour"=>80.59})
    end

    it "Raises an error for an order that doesn't exist" do
      Grocery::Order.find(150).must_raise StandardError
    end

  end
end
