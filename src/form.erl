%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 13:33
%%%-------------------------------------------------------------------
-module(form).
-author("karolinabogacka").
-behavior(application).

-include("parametres.hrl").

%% API
-export([start/2, stop/1]).

stop(_State) ->
  ok.

read()->
  Food = application:get_env(ants_pwir, food, ?AVAILABLE_FOOD),
  Colonies = application:get_env(ants_pwir, colonies, [#colony{place = #place{x = 3, y = 3}, ant_population = ?MAX_ANTS}]),
  Width = application:get_env(ants_pwir, width, ?WORLD_WIDTH),
  Height = application:get_env(ants_pwir, height, ?WORLD_HEIGHT),

  #world_data{food = Food,
    colonies = Colonies,
    width = Width,
    height = Height}.

start(_Type, _Args) ->
  Parameters = read(),
  super_main:start_link(Parameters).

