%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 11:53
%%%-------------------------------------------------------------------
-module(sole_food).

-include("parametres.hrl").
-behavior(gen_server).


%% API
-export([ init/1, handle_call/3, terminate/2, code_change/3, start_link/1, handle_cast/2, handle_info/2]).

start_link(WorldData) ->
  gen_server:start_link(?MODULE, WorldData, []).

init(WorldData) ->

  Width = WorldData#world_data.width,
  Height = WorldData#world_data.height,
  {X, Y} =  {rand:uniform(Width - 1), rand:uniform(Height - 1)},
  State = #food{pid = self(),
    size = WorldData,
    place = #place{x = X, y = Y},
    available = 3},
  stream_of_creation:notify(food, placed, State),
  {ok,State}.

terminate(_, State) ->
  stream_of_creation:notify(food, gone, State),
  ok.

code_change(_Old, State, _Add) ->
  {ok, State}.

handle_cast(_Ask, State) ->
  {noreply, State}.

handle_info(stop_sign, State) ->
  {stop, normal, State};

handle_info(_Inf, State) ->
  {noreply, State}.

handle_call({are_you_at, Place}, _From, State) ->
  {X, Y} = {(State#food.place)#place.x, (State#food.place)#place.y},
  Is = case {Place#place.x, Place#place.y} of
         {X, Y} -> true;
         _      -> false
       end,
  {reply, Is, State};

handle_call({eat}, _From, State)->
  case State#food.available of
    1 ->
      {stop, normal, {error, food_eaten}, State};
    _ ->
      NewAv = State#food.available -1,
      NState = State#food{available = NewAv},
      stream_of_creation:notify(food, bite, NState),
      {reply, {ok, food_eaten_in_part}, NState}
  end.


