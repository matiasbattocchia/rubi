require 'minitest/autorun'
require 'rubi'

include Rubi

describe Database do
  let(:db) do
    Database.new({ adapter: 'postgres',
                      host: 'localhost',
                  database: 'ds2',
                      user: 'ds2',
                  password: ''})
  end

  let(:table) do
    db.tables.find { |table| table.name == 'public.orders' }
  end

  describe 'tables' do
    it 'returns an array with database tables' do
      tables = ['public.categories',
                'public.cust_hist',
                'public.customers',
                'public.inventory',
                'public.orderlines',
                'public.orders',
                'public.products',
                'public.reorder']

      db.tables.map(&:name).sort.must_equal tables
    end
  end

  describe 'columns' do
    it 'lists table columns' do
      columns = ['public.orders.customerid',
                 'public.orders.netamount',
                 'public.orders.orderdate',
                 'public.orders.orderid',
                 'public.orders.tax',
                 'public.orders.totalamount']

      table.columns.map(&:name).sort.must_equal columns
    end
  end

  describe 'column attributes' do
    it 'recognizes primary keys' do
      c = table.columns.find { |column| column.name == 'orderid' }

      c.data_type.must_equal :integer
      c.constraint_type.must_equal :primary_key
    end

    it 'recognizes foreign keys' do
      c = table.columns.find { |column| column.name == 'orderdate' }

      c.data_type.must_equal :date
      c.constraint_type.must_be_nil
    end

    it 'recognizes normal columns' do
      c = table.columns.find { |column| column.name == 'customerid' }

      c.data_type.must_equal :integer
      c.constraint_type.must_equal :foreign_key
    end
  end

  describe 'relationships' do
    it 'lists database relationships' do
      relationships = ['fk_cust_hist_customerid',
                       'fk_orderid',
                       'fk_customerid']

      db.relationships.map(&:constraint_name).sort.must_equal relationships
    end
  end

  describe 'relationship attributes' do
    it 'describes a relationship' do
      r = db.relationships.find do |relationship|
        relationship.constraint_name == 'fk_customerid'
      end

      r.referencing_table.name.must_equal 'orders'
      r.referenced_table.name.must_equal 'customers'

      conditions = [['public.orders.customerid', 'public.customers.customerid']]

      r.conditions.sort.must_equal conditions
    end
  end
end
