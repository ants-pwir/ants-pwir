%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @doc
%%%
%%% @end
%%% Created : 01. Jan 2019 22:48
%%%-------------------------------------------------------------------
-module(super_ant).
-include("parametres.hrl").
-behavior(supervisor).

%% API
-export([ start_link/1, init/1, breed/1, kill_children/0, check_ant/ ]).

start_link(WorldData) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, WorldData).

init(_State) ->
  stream_of_creation:part_ready(?MODULE),
  {ok, {{one_for_one, 5, 1}, []}}.

breed(WorldData) ->
  CurriedBreed = fun(Colony) -> breedAnts(WorldData, Colony) end,
  lists:foreach(CurriedBreed, WorldData#world_data.colonies).

breedAnts(WorldData, Colony) ->
  breedAnts(Colony#colony.ant_population, Colony#colony.place, WorldData).

breedAnts(AntsLeft, ColonyPosition, WorldData) when AntsLeft > 0 ->
  Ant = { {ant, ColonyPosition, AntsLeft},
    {sole_ant, start_link, [ {WorldData, ColonyPosition} ]},
    temporary, brutal_kill, worker,
    [ sole_ant ]},

  supervisor:start_child(?MODULE, Ant),
  breedAnts(AntsLeft - 1, ColonyPosition, WorldData);

breedAnts(_AntsLeft, _ColonyPosition, _WorldParameters) ->
  done.

kill_children() ->
  moves:stop_children(?MODULE).

