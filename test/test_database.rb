require 'minitest/autorun'
require 'rubi'

include Rubi

describe Database, 'PostgreSQL' do
  let(:db) do
    # Database.new({ adapter: 'mysql2',
    #                   host: 'localhost',
    #               database: 'DS2',
    #                   user: 'web',
    #               password: 'web'})
    Database.new({ adapter: 'postgres',
                      host: 'localhost',
                  database: 'ds2',
                      user: 'ds2',
                  password: ''})
  end

  let(:table) do
    db.tables.find { |table| table.full_name == 'public.orders' }
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

      db.tables.map(&:full_name).sort.must_equal tables
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

      table.columns.map(&:full_name).sort.must_equal columns
    end
  end

  describe 'column attributes' do
    it 'recognizes primary keys' do
      c = table.columns.find do |column|
        column.name == 'public.orders.orderid'
      end

      c.data_type.must_equal :integer
      c.constraint_types.must_equal ['PRIMARY KEY']
    end

    it 'recognizes foreign keys' do
      c = table.columns.find do |column|
        column.name == 'public.orders.orderdate'
      end

      c.data_type.must_equal :date
      c.constraint_types.must_be_nil
    end

    it 'recognizes normal columns' do
      c = table.columns.find do |column|
        column.name == 'public.orders.customerid'
      end

      c.data_type.must_equal :integer
      c.constraint_types.must_equal ['FOREIGN KEY']
    end
  end

  describe 'relationships' do
    it 'lists database relationships' do
      relationships = ['fk_cust_hist_customerid',
                       'fk_orderid',
                       'fk_customerid']

      db.relationships.map(&:full_name).sort.must_equal relationships
    end
  end

  describe 'relationship attributes' do
    it 'describes a relationship' do
      r = db.relationships.find do |relationship|
        relationship.full_name == 'fk_customerid'
      end

      r.referencing_table.full_name.must_equal 'public.orders'
      r.referenced_table.full_name.must_equal  'public.customers'

      conditions = [['public.orders.customerid', 'public.customers.customerid']]

      r.conditions.sort.must_equal conditions
    end
  end
end
