require 'minitest/autorun'
require 'rubi'

include Rubi

describe Database, 'MySQL' do
  let(:db) do
    Database.new({ adapter: 'mysql2',
                      host: 'localhost',
                  database: 'DS2',
                      user: 'web',
                  password: 'web'})
  end

  let(:table) do
    db.tables.find { |table| table.full_name == 'DS2.ORDERS' }
  end

  describe 'tables' do
    it 'returns an array with database tables' do
      tables = ['DS2.CATEGORIES',
                'DS2.CUSTOMERS',
                'DS2.CUST_HIST',
                'DS2.INVENTORY',
                'DS2.ORDERLINES',
                'DS2.ORDERS',
                'DS2.PRODUCTS',
                'DS2.REORDER']

      db.tables.map(&:full_name).sort.must_equal tables
    end
  end

  describe 'columns' do
    it 'lists table columns' do
      columns = ['DS2.ORDERS.CUSTOMERID',
                 'DS2.ORDERS.NETAMOUNT',
                 'DS2.ORDERS.ORDERDATE',
                 'DS2.ORDERS.ORDERID',
                 'DS2.ORDERS.TAX',
                 'DS2.ORDERS.TOTALAMOUNT']

      table.columns.map(&:full_name).sort.must_equal columns
    end
  end

  describe 'column attributes' do
    it 'recognizes primary keys' do
      c = table.columns.find do |column|
        column.full_name == 'DS2.ORDERS.ORDERID'
      end

      c.data_type.must_equal :int
      c.constraint_types.must_equal 'PRIMARY KEY'
    end

    it 'recognizes foreign keys' do
      c = table.columns.find do |column|
        column.full_name == 'DS2.ORDERS.ORDERDATE'
      end

      c.data_type.must_equal :date
      c.constraint_types.must_be_nil
    end

    it 'recognizes normal columns' do
      c = table.columns.find do |column|
        column.full_name == 'DS2.ORDERS.CUSTOMERID'
      end

      c.data_type.must_equal :int
      c.constraint_types.must_equal 'FOREIGN KEY'
    end
  end

  describe 'relationships' do
    it 'lists database relationships' do
      relationships = ['DS2.CUST_HIST.FK_CUST_HIST_CUSTOMERID',
                       'DS2.ORDERLINES.FK_ORDERID',
                       'DS2.ORDERS.FK_CUSTOMERID']

      db.relationships.map(&:full_name).sort.must_equal relationships
    end
  end

  describe 'relationship attributes' do
    it 'describes a relationship' do
      r = db.relationships.find do |relationship|
        relationship.full_name == 'DS2.ORDERS.FK_CUSTOMERID'
      end

      r.referencing_table.full_name.must_equal 'DS2.ORDERS'
      r.referenced_table.full_name.must_equal  'DS2.CUSTOMERS'

      join_conditions =
        [['DS2.ORDERS.CUSTOMERID', 'DS2.CUSTOMERS.CUSTOMERID']]

      r.join_conditions.sort.must_equal join_conditions
    end
  end
end
