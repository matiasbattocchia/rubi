require 'minitest/autorun'
require 'rubi'
require 'pry'

include Rubi

def connection
  { adapter: 'postgres',
       host: 'localhost',
   database: 'ds2',
       user: 'ds2',
   password: ''}
end

describe Database do
  describe 'tables' do
    it 'lists database tables' do
      tables = ["categories", "cust_hist", "customers", "inventory",
                "orderlines", "orders", "products", "reorder"]

      db = Database.new(connection)
      db.graph.vertices.map(&:name).sort.must_equal(tables)
    end
  end
end
