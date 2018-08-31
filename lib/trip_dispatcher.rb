require 'csv'
require 'time'
require "pry"

require_relative 'user'
require_relative 'trip'
require_relative 'driver'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(user_file = 'support/users.csv',
      trip_file = 'support/trips.csv',
      driver_file = 'support/drivers.csv')
      @passengers = load_users(user_file) #array of all Users from users csv
      @drivers = load_drivers(driver_file) # array of all Drivers from drivers csv
      @trips = load_trips(trip_file) #array of all Trips from trips csv
    end

    def load_users(filename)
      users = []

      CSV.read(filename, headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        users << User.new(input_data)
      end
      return users
    end


    def load_trips(filename)
      trips = []
      trip_data = CSV.open(filename, 'r', headers: true,
        header_converters: :symbol)

        trip_data.each do |raw_trip|
          driver = find_driver(raw_trip[:driver_id].to_i) #instance of Driver class
          passenger = find_passenger(raw_trip[:passenger_id].to_i) # instance of User class
          parsed_trip = {
            id: raw_trip[:id].to_i,
            driver: driver,
            passenger: passenger,
            start_time: Time.parse(raw_trip[:start_time]),
            end_time: Time.parse(raw_trip[:end_time]),
            cost: raw_trip[:cost].to_f,
            rating: raw_trip[:rating].to_i
          }

          trip = Trip.new(parsed_trip)
          passenger.add_trip(trip) # User.add_trip(trip) adds to @trips []
          driver.add_driven_trip(trip) # Driver.add_trip(trip) adds to @trips []
          trips << trip # TripDispatcher.load_trips(filename) adds to trips [], which is returned by load_trips. init loads trips to TripDisp @trips
        end

        return trips
      end

      def load_drivers(filename)
        drivers = []

        CSV.read(filename, headers: true).each do |line|
          input_data = {}

          user = find_passenger(line[0].to_i)

          input_data[:id] = line[0].to_i
          input_data[:vehicle_id] = line[1]
          input_data[:status] = line[2].to_sym

          input_data[:name] = user.name
          input_data[:phone_number] = user.phone_number
          input_data[:trips] = user.trips

          drivers << Driver.new(input_data)
        end
        return drivers
      end

      def find_driver(id)
        check_id(id)
        return @drivers.find { |driver| driver.id == id } #instance of Driver class
      end

      def available_driver
        available = @drivers.find { |driver| driver.status == :AVAILABLE }
        # if no available drivers, argument error?
        # rescue?
        return available
      end

      def find_passenger(id)
        check_id(id)
        return @passengers.find { |passenger| passenger.id == id }
      end

      def inspect
        return "#<#{self.class.name}:0x#{self.object_id.to_s(16)} \
        #{trips.count} trips, \
        #{drivers.count} drivers, \
        #{passengers.count} passengers>"
      end

      def request_trip(user_id)

        passenger_trip = {}
        # can we rename "passenger_trip" to "new_in_progress_trip"?

        passenger_trip[:id] = user_id,
        passenger_trip[:driver] = available_driver,
        passenger_trip[:passenger] = find_passenger(user_id),
        passenger_trip[:start_time] = Time.now

        trip = Trip.new(passenger_trip)

        passenger_trip[:passenger].add_trip(trip) # User.add_trip(trip) adds to @trips []
        passenger_trip[:driver].add_driven_trip(trip) # Driver.add_trip(trip) adds to @trips []
        @trips << trip
        # should be @trips?

        return trips
      end

      # user_id, x
      # auto assign driver (first driver status available) x
      # PASSENGER????????
      # start time = Time.now
      # end TIME = nil (IN PROG)
      # cost = nil
      # rating = nil

      # helper method in Driver:
      # add new_in_progress_trip to driver.driven_trips [] (.add_driven_trip)
      # set driver.status = :unavailable

      # helper method in User:
      # add new trip to user.trips [] (.add_trip)

      # add new trip to trip_dispatcher's @trips
      # will need to refactor
      # return new_in_progress_trip

      # wave 1&2 code:
      # ignores in-progress trips (if end time) is nil not included
      # write explicit tests for this situation
      private

      def check_id(id)
        if id.nil? || id <= 0
          raise ArgumentError, "ID cannot be blank or less than zero. (got #{id})"
        end
      end


    end
  end
