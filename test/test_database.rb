require 'minitest/autorun'
require 'rubi'
require 'pry'

include Rubi

def connection
  {adapter: 'postgres',
   host: 'localhost',
   database: 'ds2',
   user: 'ds2',
   password: ''}
end

describe Database do
  describe 'new' do
    it 'picks up the topology of the given database' do
      database = ''

      Database.new(connection).must_equal(database)
    end
  end
end
