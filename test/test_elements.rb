require 'minitest/autorun'
require 'rubi'
require 'yaml'

include Rubi

describe 'Elements' do
  let(:yaml_file) do
    <<-EOF
      # First field describes an element as
      # an attribute, a fact, or something else;
      # its value gives it a name.
      #
      # Table field maps an element to a physical
      # table. The table full name is required to
      # distinguish the database where it is stored.
      # It will not be necessary if there are not
      # table name colissions.
      #
      # Attribute names shall determine its table's
      # name via inflections.
      #
      # If table is not given, then columns must,
      # with full name. An attribute can span
      # several tables.
      #
      # For attributes, if no columns are specified
      # then all columns from the source table will
      # become forms of the attribute. Constrained
      # columns (primary and foreign keys) and
      # columns named "id" or ending in "_id" will
      # be considered keys and hence hidden forms.
      #
      # Column names will produce form names
      # gratiously but they can also be specified.
      #
      # Forms enclose an expression that commonly
      # is the column that represents, even though
      # it may be a more complex formulation, i.e.
      # an operation involving two columns.
      #
      # Forms declaration behaviour is exclusive;
      # if the intention is to map all table columns
      # with default names except some of them,
      # "inclusive forms" can be used.
      #
      # In the normal mode if only a name is
      # portrayed, it will be mapped to a column.
      # Otherway a hash with form name and expression
      # has to be provided, including other options
      # such as role (id/foreign id), format
      # (number/string/...), sort (ascending/descending),
      # hidden (true/false).
      #
      #

      attribute: origin airport
      table: warehouse.public.airports

      forms:
        - {name: IATA code, expr: airport_id, role: id}
        - long name   # This form will seek long_name column.

      qualifies:
        - element: passengers carried
          key: origin_airport   # Not necessary if foreign key column
                                # is named origin_airport_id.

      ---

      attribute: destination airport
      table: warehouse.public.airports

      qualifies:
        - element: passengers carried
          key: destination_airport

      ---

      attribute: aircraft
      table: things.public.aircrafts
      qualifies: passengers carried

      ---

      attribute: day
      qualifies: passengers carried

      ---

      attribute: month
      has: days
      qualifies: passengers carried

      ---

      attribute: year
      has:
        - months
        - strange things

      ---

      attribute: strange thing
      has: years

      ---

      fact: Passengers carried
      expressions:
        - warehouse.public.flights.passengers
        - warehouse.public.flights_monthly.passengers
    EOF
  end

  describe Universe do
    it "resembles elements' topology" do
      elements = YAML.load_stream(yaml_file)
      u = Universe.new(elements)


    end
  end
end



