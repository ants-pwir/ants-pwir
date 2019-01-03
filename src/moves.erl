%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 11:51
%%%-------------------------------------------------------------------
-module(moves).
-include("parametres.hrl").


%% API
-export([stop_children/1, next_place/2, valid_place/2, next_to_target/3]).

stop_children(SName) ->
  [PID ! stop_sign || {_, PID, _, _} <- supervisor:which_children(SName)].

next_place(Size, Place) ->
  {X, Y} = {Place#place.x, Place#place.y},
  Where = rand:uniform(8),
  case Where of
    1 -> NPlace = #place{x=X, y=Y+1};
    2  -> NPlace = #place{x=X, y=Y-1};
    3  -> NPlace = #place{x=X+1, y=Y};
    4  -> NPlace = #place{x=X-1, y=Y};
    5 -> NPlace = #place{x=X-1, y=Y+1};
    6 -> NPlace = #place{x=X+1, y=Y+1};
    7 -> NPlace = #place{x=X-1, y=Y-1};
    8 -> NPlace = #place{x=X+1, y=Y-1}
  end,
  Valid_Where = valid_place(Size, NPlace),
  case Valid_Where of
    true -> NPlace;
    _ -> next_place(Size, Place)
  end.

valid_place(Size, Place) ->
  X = Place#place.x,
  Y = Place#place.y,
  if
    X >0, Y>0, X<Size#world_data.width, Y<Size#world_data.height -> true;
    true -> false
  end.

next_to_target(Size, Place, {target_pos, undefined, undefined}) ->
  next_place(Size, Place);

next_to_target(_Size, Place, Target) ->
  {X, Y} = {Target#target_pos.x - Place#place.x, Target#target_pos.y - Place#place.y},
  if
    X >  0, Y >  0 -> #place{x=Place#place.x+1, y=Place#place.y+1};
    X >  0, Y <  0 -> #place{x=Place#place.x+1, y=Place#place.y-1};
    X >  0, Y == 0 -> #place{x=Place#place.x+1, y=Place#place.y};
    X <  0, Y == 0 -> #place{x=Place#place.x-1, y=Place#place.y};
    X == 0, Y >  0 -> #place{x=Place#place.x, y=Place#place.y+1};
    X == 0, Y <  0 -> #place{x=Place#place.x, y=Place#place.y-1};
    X <  0, Y >  0 -> #place{x=Place#place.x-1, y=Place#place.y+1};
    X <  0, Y <  0 -> #place{x=Place#place.x-1, y=Place#place.y-1};
    X == 0, Y == 0 -> #place{x=Place#place.x, y=Place#place.y}
  end.



