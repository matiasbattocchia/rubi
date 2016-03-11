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
    db.find_table('DS2.DS2.ORDERS')
  end

  describe 'tables' do
    it 'returns an array with database tables' do
      tables = ['DS2.DS2.CATEGORIES',
                'DS2.DS2.CUSTOMERS',
                'DS2.DS2.CUST_HIST',
                'DS2.DS2.INVENTORY',
                'DS2.DS2.ORDERLINES',
                'DS2.DS2.ORDERS',
                'DS2.DS2.PRODUCTS',
                'DS2.DS2.REORDER']

      db.tables.map(&:full_name).sort.must_equal tables
    end
  end

  describe 'columns' do
    it 'lists table columns' do
      columns = ['DS2.DS2.ORDERS.CUSTOMERID',
                 'DS2.DS2.ORDERS.NETAMOUNT',
                 'DS2.DS2.ORDERS.ORDERDATE',
                 'DS2.DS2.ORDERS.ORDERID',
                 'DS2.DS2.ORDERS.TAX',
                 'DS2.DS2.ORDERS.TOTALAMOUNT']

      table.columns.map(&:full_name).sort.must_equal columns
    end
  end

  describe 'column attributes' do
    it 'recognizes data types' do
      table.find_column('DS2.DS2.ORDERS.ORDERID')
        .data_type.must_equal :int

      table.find_column('DS2.DS2.ORDERS.ORDERDATE')
        .data_type.must_equal :date
    end
  end

  describe 'relationships' do
    it 'lists database relationships' do
      relationships = ['DS2.DS2.CUST_HIST.FK_CUST_HIST_CUSTOMERID',
                       'DS2.DS2.ORDERLINES.FK_ORDERID',
                       'DS2.DS2.ORDERS.FK_CUSTOMERID']

      db.relationships.map(&:full_name).sort.must_equal relationships
    end
  end

  describe 'relationship attributes' do
    it 'describes a relationship' do
      r = db.find_relationship('DS2.DS2.ORDERS.FK_CUSTOMERID')

      r.referencing_table.full_name.must_equal 'DS2.DS2.ORDERS'
      r.referenced_table.full_name.must_equal  'DS2.DS2.CUSTOMERS'

      r.referencing_columns.map(&:full_name).sort
        .must_equal ['DS2.DS2.ORDERS.CUSTOMERID']

      r.referenced_columns.map(&:full_name).sort
        .must_equal ['DS2.DS2.CUSTOMERS.CUSTOMERID']
    end
  end
end
