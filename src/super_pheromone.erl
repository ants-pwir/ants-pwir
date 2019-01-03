%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 13:26
%%%-------------------------------------------------------------------
-module(super_pheromone).
-behavior(supervisor).

%% API
-export([ start_link/1, init/1, kill_children/0, place_pheromone/3]).

-include("parametres.hrl").

start_link(WorldData) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, WorldData).

init(_State) ->
  stream_of_creation:part_ready(?MODULE),
  {ok, {{one_for_one, 3, 60}, []}}.

kill_children() ->
  moves:stop_children(?MODULE).

place_pheromone(WorldData, Place, FoodPlace) ->
  Pheromone = {{pheromone, Place},
    {sole_pheromone, start_link, [{WorldData, Place, FoodPlace}]},
    temporary, brutal_kill, worker,
    [sole_pheromone]},
  supervisor:start_child(?MODULE, Pheromone).

