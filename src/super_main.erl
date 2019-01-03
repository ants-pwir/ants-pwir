%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 13:41
%%%-------------------------------------------------------------------
-module(super_main).
-behavior(supervisor).

%% API
-export([start_link/1, init/1, populate/1, kill_everyone/0]).

start_link(WorldData) ->
  supervisor: start_link({local, ?MODULE}, ?MODULE, WorldData).

kill_everyone() ->
  super_super:restart().

populate(Data) ->
  super_super:populate(Data).

init(WorldData) ->
  Arg = [ WorldData ],

  CreationStream = {stream_of_creation,
    {stream_of_creation, start_link, []},
    permanent, 1000, worker,
    [ stream_of_creation ]},

  Controls = {controls,
    {controls, start_link, Arg},
    permanent, 1000, worker,
    [ controls ]},

  SuperSuper = {super_super,
    {super_super, start_link, Arg},
    permanent, brutal_kill, supervisor,
    [ super_super ]},

  {ok, {{one_for_one, 1, 60},
    [ CreationStream, Controls, SuperSuper ]}}.

