%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Jan 2019 21:33
%%%-------------------------------------------------------------------
-module(super_raindrop).
-author("karolinabogacka").
-include("parametres.hrl").
-behavior(supervisor).

-export([ start_link/1, init/1, make_rain/1, kill_children/0 ]).

start_link(WorldData) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, WorldData).

init(_State) ->
  stream_of_creation:part_ready(?MODULE),
  {ok, {{one_for_one, 5, 1}, []}}.


make_rain(WorldData) ->
  Density = ?RAIN_DENSITY,
  make_more_rain(0, Density, WorldData).

make_more_rain(Placed, Density, WorldData ) when Placed < Density ->
  Rain = {{rain, Placed+1}, {sole_raindrop, start_link, [WorldData]},
    temporary, brutal_kill, worker,
    [sole_raindrop]},
  supervisor:start_child(?MODULE, Rain),
  make_more_rain(Placed+1, Density, WorldData);

make_more_rain(_Placed, _Density, _WorldData) ->
  done.

kill_children() ->
  moves:stop_children(?MODULE).

