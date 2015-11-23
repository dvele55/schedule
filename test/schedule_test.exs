defmodule ScheduleTest do
  use ExUnit.Case
  use EQC.ExUnit

  property "Union comutativity" do
    forall {x, y} <- {list({int, int}), list({int, int})} do
       s_x = Schedule.schedule(x)
       s_y = Schedule.schedule(y)
       Schedule.union(s_x, s_y) == Schedule.union(s_y, s_x)
    end
  end

  property "Union associativity" do
    forall {x, y, z}
      <- { list({int, int}), list({int, int}), list({int, int}) } do
      s_x = Schedule.schedule(x)
      s_y = Schedule.schedule(y)
      s_z = Schedule.schedule(z)
      Schedule.union(Schedule.union(s_x, s_y), s_z) ==
          Schedule.union(s_x, Schedule.union(s_y, s_z))
    end
  end

  property "Union neutral element" do
    forall x <- list({int, int}) do
      s_x = Schedule.schedule(x)
      Schedule.union(s_x, Schedule.union) == s_x
			  and Schedule.union(Schedule.union, s_x) == s_x
    end
  end

  property "Intesection comutativity" do
    forall {x, y} <- {list({int, int}), list({int, int})} do
       s_x = Schedule.schedule(x)
       s_y = Schedule.schedule(y)
       Schedule.intersection(s_x, s_y) ==
         Schedule.intersection(s_y, s_x)
    end
  end

  property "Intersection associativity" do
    forall {x, y, z}
      <- { list({int, int}), list({int, int}), list({int, int}) } do
      s_x = Schedule.schedule(x)
      s_y = Schedule.schedule(y)
      s_z = Schedule.schedule(z)
      Schedule.intersection(Schedule.intersection(s_x, s_y), s_z) ==
        Schedule.intersection(s_x, Schedule.intersection(s_y, s_z))
    end
  end

  property "Intersection neutral element" do
    forall x <- list({int, int}) do
      s_x = Schedule.schedule(x)
      Schedule.intersection(s_x, Schedule.intersection) == s_x
        and Schedule.intersection(Schedule.intersection, s_x) == s_x
    end
  end

  property "Complement union" do
    forall x <- list({int, int}) do
			s_x = Schedule.schedule(x)
			Schedule.union(Schedule.complement(s_x), s_x) == [{nil, nil}]
		end
	end

	property "Complement intersection" do
		forall x <- list({int, int}) do
			s_x = Schedule.schedule(x)
			Schedule.intersection(Schedule.complement(s_x), s_x) == []
		end
	end
		
	property "Complement double" do
		forall x <- list({int, int}) do
			s_x = Schedule.schedule(x)
			Schedule.complement(Schedule.complement(s_x)) == s_x
		end
	end

	property "Schedule of reducing is upperset of schedule" do
		forall x <- list({int, int}) do
			s_x = Schedule.schedule(x)
			r_x = Schedule.reduce(s_x)
			Schedule.intersection(s_x, r_x) == s_x
		end
	end

	test "Reduce schedule" do
		schedule1 = [{nil, 1}, {3, 5}]
		schedule2 = [{-1, 1}, {3, nil}]
		schedule3 = [{-1, 1}, {3, 5}]
		assert Schedule.reduce(schedule1) == [{nil, 5}]
		assert Schedule.reduce(schedule2) == [{-1, nil}]
		assert Schedule.reduce(schedule3) == [{-1, 5}]
	end
end
