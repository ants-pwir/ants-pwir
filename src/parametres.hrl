%Defining the modifiable parametres
%This is the place you want to go if you're dreaming of another, bigger ant colony
%Or maybe a smaller one

-define(MIN_ANTS, 2).
-define(MAX_ANTS, 50).
-define(AVAILABLE_FOOD, 20).
-define(PHEROMONE_TIME, 24000).


%And there you have basic records

-record(target_pos, {x,y}).
-record(place, {x,y}).

-record(ant, {pid, place, colony_place, size, target_pos = #target_pos{},
  next_to_food = false, food_place = undefined}).
-record(world_data, {width, height, food, ants, colonies}).
-record(colony, {place, ant_population}).
-record(food, {pid, size, place, available}).
-record(pheromone, {pid, place, food_place, size}).