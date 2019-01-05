%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Jan 2019 21:33
%%%-------------------------------------------------------------------
-module(sole_raindrop).
-author("karolinabogacka").
-include("parametres.hrl").

-behavior(gen_server).

-export([ init/1, terminate/2, code_change/3, start_link/1, handle_cast/2, handle_info/2, handle_info/3, what_is_at/2, what_is_at/3]).

start_link(WorldData) ->
  gen_server:start_link(?MODULE, WorldData, []).

init(WorldData) ->
  Width = WorldData#world_data.width,
  Height = WorldData#world_data.height,
  {X, Y} =  {rand:uniform(Width - 1), rand:uniform(Height - 1)},
  State = #rain{pid = self(),
    place = #place{x = X, y = Y}},
  stream_of_creation:notify(rain, fell_on, State),
  check_ants(State, WorldData),
  erlang:send_after(30, self(), next_rain),
  {ok,State}.

terminate(_, State) ->
  stream_of_creation:notify(rain, has_stopped_falling, State),
  ok.

code_change(_Old, State, _Add) ->
  {ok, State}.

handle_cast(_Ask, State) ->
  {noreply, State}.

handle_info(stop_sign, State) ->
  {stop, normal, State};

handle_info(_Inf, State) ->
  {noreply, State}.

handle_info(next_rain, State, WorldData) ->
  %stream_of_creation:notify(help, help_me_with_state,State),
  Width = WorldData#world_data.width,
  Height = WorldData#world_data.height,
  {X, Y} =  {rand:uniform(Width - 1), rand:uniform(Height - 1)},
  State = #rain{pid = self(),
    place = #place{x = X, y = Y}},
  stream_of_creation:notify(rain, fell_on, State),
  check_ants(State, WorldData),
  erlang:send_after(300, self(), next_rain),
  {ok,State}.

check_ants(State, WorldData) ->
  ColonySize = ?COLONY_SIZE,
  CurriedCheck = fun(Colony) -> what_is_at(State#rain.place, Colony#colony.place, ColonySize) end,
  lists:foreach(CurriedCheck, WorldData#world_data.colonies).

what_is_at(Place, ColonyPlace, ColonySize) when erlang:abs(Place#place.x - ColonyPlace#place.x) < ColonySize, erlang:abs(Place#place.y - ColonyPlace#place.y) < ColonySize ->
  stream_of_creation:notify(rain, at_colony, Place),
  {colony, ColonyPlace};

what_is_at(Place, _ColonyPlace, _ColonySize) ->
  stream_of_creation:notify(rain, not_at_colony, Place),
  AllAnts = supervisor:which_children(super_ant),
  what_is_at(Place, AllAnts).

what_is_at(Place, [{_Id, Ant, _Type, _Modules} | Rest ]) ->
  gen_server:call(Ant, {are_you_there, Place}),
  what_is_at(Place, Rest);

what_is_at(_Position, []) ->
  erlang:send_after(30, self(), next_rain),
  {nothing}.

