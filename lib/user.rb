module RideShare
  class User
    attr_reader :id, :name, :phone_number, :trips

    def initialize(input)
      if input[:id].nil? || input[:id] <= 0
        raise ArgumentError, "ID cannot be blank or less than zero" \
                             " (got #{input[:id]})."
      end

      @id = input[:id]
      @name = input[:name]
      @phone_number = input[:phone]
      @trips = input[:trips].nil? ? [] : input[:trips]
    end

    def add_trip(trip)
      @trips << trip
    end

    def net_expenditures
      sum = 0
      @trips.each do |trip|
        if trip.cost == nil
          sum += 0
        else
          sum += trip.cost
        end
      end
      return sum
    end

    def total_time_spent
      total_time = 0
      @trips.each do |trip|
        if trip.end_time == nil
          total_time += 0
        else
          total_time += trip.duration
        end
      end
      return total_time
    end

  end
end
