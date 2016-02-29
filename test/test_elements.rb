require 'minitest/autorun'
require 'rubi'

include Rubi

describe Elements do
  let(:db) do
    Database.new({ adapter: 'postgres',
                      host: 'localhost',
                  database: 'ds2',
                      user: 'ds2',
                  password: ''})
  end

  let(:table) do
    db.tables.find { |table| table.full_name == 'public.orders' }
  end

  describe Fact do
    it 'describes a fact' do
      class Profit < Fact do
        fact 'ds2.orders.netamount'
      end
    end
      class Order < Attribute do
        id 'ds2.orders.orderid'
        date 'ds2.orders.orderdate'
      end

      class Category < Attribute do
        id 'ds2.categories.category'
        name 'ds2.categories.categoryname'
      end

      class Product < Attribute do
        table 'ds2.products'
        id 'prod_id'
        _others 'title', 'actor'
      end

      attribute Orderline do
        table 'ds2.orderlines'
        id 'orderlineid'
        date 'orderdate'
      end

  end
end
