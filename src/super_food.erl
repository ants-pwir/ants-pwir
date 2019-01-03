%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 12:22
%%%-------------------------------------------------------------------
-module(super_food).
-include("parametres.hrl").


%% API
-export([ start_link/1, init/1, place/1, kill_children/0]).

start_link(WorldData) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, WorldData).

init(State) ->
  stream_of_creation:part_ready(?MODULE),
  {ok, {{one_for_one, State#world_data.food, 1}, []}}.

kill_children() ->
  moves:stop_children(?MODULE).

place(Data) ->
  Available = ?AVAILABLE_FOOD,
  place_food(0, Available, Data).

place_food(Placed, Available, Data) when Placed < Available ->
  Food = {{food, Placed +1}, {sole_food, start_link, [Data]},
    temporary, brutal_kill, worker,
    [sole_food]},
  supervisor:start_child( ?MODULE, Food),
  place_food(Placed + 1, Available, Data);

place_food(_Placed, _Available, _Data) ->
  done.

