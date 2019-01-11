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

-export([ init/1, terminate/3, code_change/3, start_link/1, handle_cast/2, handle_info/2, handle_call/3]).

start_link(WorldData) ->
  gen_server:start_link(?MODULE, WorldData, []).

init(WorldData) ->
  Width = WorldData#world_data.width,
  Height = WorldData#world_data.height,
  {X, Y} =  {rand:uniform(Width - 1), rand:uniform(Height - 1)},
  State = #rain{pid = self(),
    place = #place{x = X, y = Y}},
  stream_of_creation:notify(rain, fell_on, State),
  {ok,State,900}.

terminate(_, _SName, _State) ->
  {normal,shutdown}.

code_change(_Old, State, _Add) ->
  {ok, State}.

handle_cast(_Ask, State) ->
  {noreply, State}.

handle_info(stop_sign, State) ->
  stream_of_creation:notify(rain, has_stopped_falling, State),
  {stop, normal, State};

handle_info(timeout, State) ->
  Width = ?WORLD_WIDTH,
  Height = ?WORLD_HEIGHT,
  X =  rand:uniform(Width - 1),
  Y = rand:uniform(Height - 1),
  NewPlace = #place{x=X, y=Y},
  NewState = State#rain{place = NewPlace},
  stream_of_creation:notify(rain, falls_again, NewState),
  {noreply,NewState,900};

handle_info(_Inf, State) ->
  {noreply, State}.

handle_call({are_you}, _From, State) ->
  {reply, true, State};

handle_call({are_you_at, Place}, _From, State) ->
  {X, Y} = {(State#rain.place)#place.x, (State#rain.place)#place.y},
  Ans = case {Place#place.x, Place#place.y} of
          {X, Y} -> true;
          _      -> false
        end,
  {reply, Ans, State}.

