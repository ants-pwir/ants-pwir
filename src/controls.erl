%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 13:45
%%%-------------------------------------------------------------------
-module(controls).
-behavior(gen_server).

-include("parametres.hrl").

%% to start, write: observer:start(),application:start(ants_pwir),controls:start_ants().
%% in the rebar3 shell
%% also, this syntax: stream_of_creation:notify( ant, a_bug_is_found, Target),
%% is useful for basic debugging

%% API
-export([init/1, handle_call/3, terminate/2, code_change/3, handle_cast/2, handle_info/2, start_link/1, start_ants/0, stop_ants/0, get_data/0]).

start_link(WorldData) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, WorldData, []).

start_ants() ->
  gen_server:call(?MODULE,start_ants ).

stop_ants() ->
  gen_server:call(?MODULE, stop_ants).

get_data() ->
  gen_server:call(?MODULE, get_data).

terminate(_, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

init(WorldData) ->
  stream_of_creation:part_ready(?MODULE),
  {ok, {stopped, WorldData}}.

handle_call(start_ants, _From, {stopped, WorldData}) ->
  super_main:populate(WorldData),
  {reply, started, {started, WorldData}};

handle_call(start_ants, _From, {started, _WorldData} = State) ->
  {reply, already_started, State};

handle_call(stop_ants, _From, {started, State}) ->
  super_main:kill_everyone(),
  {reply, stopped, {stopped, State}};

handle_call(stop_ants, _From, {stopped, _WorldData} = State) ->
  {reply, already_stopped, State};

handle_call(get_data, _From, {StateName, WorldData} = State) ->
  Width = WorldData#world_data.width,
  Height = WorldData#world_data.height,
  IsStarted = StateName =:= started,

  {reply, { {width, Width}, {height, Height}, {simulation_started, IsStarted} }, State}.
