%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @doc
%%%
%%% @end
%%% Created : 01. Jan 2019 22:49
%%%-------------------------------------------------------------------
-module(super_super).
-include("parametres.hrl").
-behavior(supervisor).


%% API
-export([ start_link/1, init/1, populate/1, restart/0 ]).

start_link(WorldData) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, WorldData).

init(WorldData) ->
  Arg = [ WorldData ],

  SuperPheromone = {super_pheromone,
    {super_pheromone, start_link, Arg},
    permanent, brutal_kill, supervisor,
    [ super_pheromone ]},

  SuperFood = {super_food,
    {super_food, start_link, Arg},
    permanent, brutal_kill, supervisor,
    [ super_food ]},

  SuperAnts = {super_ant,
    {super_ant, start_link, Arg},
    permanent, brutal_kill, supervisor,
    [ super_ant ]},


  {ok, {{one_for_all, 1, 60},
    [SuperPheromone, SuperFood, SuperAnts]}}.

populate(Parameters) ->
  super_food:place(Parameters),
  super_ant:breed(Parameters),
  done.

restart() ->
  super_food:kill_children(),
  super_ant:kill_children(),
  done.

