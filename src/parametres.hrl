%Defining the modifiable parametres
%This is the place you want to go if you're dreaming of another, bigger ant colony
%Or maybe a smaller one

-define(MAX_ANTS, 5).
-define(AVAILABLE_FOOD, 20).
-define(PHEROMONE_TIME, 24000).
-define(RAIN_DENSITY, 10).
-define(COLONY_SIZE, 3).
-define(WORLD_WIDTH, 15).
-define(WORLD_HEIGHT,15).

%And there you have basic records

-record(target_pos, {x,y}).
-record(place, {x,y}).

-record(ant, {pid, place, colony_place, size, target_pos = #target_pos{},
  next_to_food = false, food_place = undefined}).
-record(world_data, {width, height, food, ants, colonies}).
-record(colony, {place, ant_population}).
-record(food, {pid, size, place, available}).
-record(pheromone, {pid, place, food_place, size}).
-record(rain, {pid, place}).