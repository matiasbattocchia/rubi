require 'minitest/autorun'
require 'rubi'

include Rubi

describe Database, 'PostgreSQL' do
  let(:db) do
    Database.new({ adapter: 'postgres',
                      host: 'localhost',
                  database: 'ds2',
                      user: 'ds2',
                  password: ''})
  end

  let(:table) do
    db.find_table('ds2.public.orders')
  end

  describe 'tables' do
    it 'returns an array with database tables' do
      tables = ['ds2.public.categories',
                'ds2.public.cust_hist',
                'ds2.public.customers',
                'ds2.public.inventory',
                'ds2.public.orderlines',
                'ds2.public.orders',
                'ds2.public.products',
                'ds2.public.reorder']

      db.tables.map(&:full_name).sort.must_equal tables
    end
  end

  describe 'columns' do
    it 'lists table columns' do
      columns = ['ds2.public.orders.customerid',
                 'ds2.public.orders.netamount',
                 'ds2.public.orders.orderdate',
                 'ds2.public.orders.orderid',
                 'ds2.public.orders.tax',
                 'ds2.public.orders.totalamount']

      table.columns.map(&:full_name).sort.must_equal columns
    end
  end

  describe 'column attributes' do
    it 'recognizes data types' do
      table.find_column('ds2.public.orders.orderid')
        .data_type.must_equal :integer

      table.find_column('ds2.public.orders.orderdate')
        .data_type.must_equal :date
    end
  end

  describe 'relationships' do
    it 'lists database relationships' do
      relationships = ['ds2.public.cust_hist.fk_cust_hist_customerid',
                       'ds2.public.orderlines.fk_orderid',
                       'ds2.public.orders.fk_customerid']

      db.relationships.map(&:full_name).sort.must_equal relationships
    end
  end

  describe 'relationship attributes' do
    it 'describes a relationship' do
      r = db.find_relationship('ds2.public.orders.fk_customerid')

      r.referencing_table.full_name.must_equal 'ds2.public.orders'
      r.referenced_table.full_name.must_equal  'ds2.public.customers'

      r.referencing_columns.map(&:full_name).sort
        .must_equal ['ds2.public.orders.customerid']

      r.referenced_columns.map(&:full_name).sort
        .must_equal ['ds2.public.customers.customerid']
    end
  end
end
