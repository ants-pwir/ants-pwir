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
-export([init/1, handle_call/3, terminate/2, code_change/3, handle_cast/2, handle_info/2, start_link/1, start_ants/0, stop_ants/0, get_data/0,start_rain/0,stop_rain/0]).

start_link(WorldData) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, WorldData, []).

start_ants() ->
  gen_server:call(?MODULE,start_ants ).

stop_ants() ->
  gen_server:call(?MODULE, stop_ants).

get_data() ->
  gen_server:call(?MODULE, get_data).

start_rain() ->
  gen_server:call(?MODULE, start_rain).

stop_rain() ->
  gen_server:call(?MODULE, stop_rain).

terminate(_, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

read_chars(P,N)->
  P=io:get_chars("command>",N).

handle_info(read_from, State) ->
  io:fwrite("Aplikacja symulująca zachowanie mrówek w trakcie deszczu. ~n",[]),
  io:fwrite("Wpisz sa żeby rozpocząć ruch mrówek, ea żeby go zakończyć. ~n",[]),
  io:fwrite("Wpisz sr żeby rozpocząć deszcz, er żeby go zakończyć. ~n",[]),
  io:fwrite("Wpisz gd aby uzyskać dane symulacji. ~n",[]),
  P="",
  read_chars(P,2),
  stream_of_creation:notify(P,State),
  case P of
    "sa" ->
      io:fwrite("Zacząłeś ruch mrówek. ~n",[]),
      gen_server:call(?MODULE,start_ants );
    "ea" ->
      io:fwrite("Zakończyłeś ruch mrówek",[]),
      gen_server:call(?MODULE, stop_ants);
    "sr" ->
      io:fwrite("Zacząłeś deszcz",[]),
      gen_server:call(?MODULE, start_rain);
    "er" ->
      io:fwrite("Zakończyłeś deszcz",[]),
      gen_server:call(?MODULE, stop_rain);
    "gd" ->
      io:fwrite("Dane symulacji",[]),
      gen_server:call(?MODULE, get_data);
    "" ->
      io:fwrite("Nic nie podałeś",[]);
    true ->
      io:fwrite("Nieznana komenda",[])
  end,
  io:fwrite("Aplikacja symulująca zachowanie mrówek w trakcie deszczu. ~n",[]),
  io:fwrite("Wpisz sa żeby rozpocząć ruch mrówek, ea żeby go zakończyć. ~n",[]),
  io:fwrite("Wpisz sr żeby rozpocząć deszcz, er żeby go zakończyć. ~n",[]),
  io:fwrite("Wpisz gd aby uzyskać dane symulacji. ~n",[]),
  erlang:send_after(5, self(), read_from),
  {ok, State};

handle_info(_Info, State) ->
  {noreply, State}.

init(WorldData) ->
  stream_of_creation:part_ready(?MODULE),
  erlang:send_after(200, self(), read_from),
  {ok, {stopped, no_rain, WorldData}}.

handle_call(start_ants, _From, {stopped, Rain, WorldData}) ->
  super_main:populate(WorldData),
  {reply, started, {started, Rain, WorldData}};

handle_call(start_ants, _From, {started, _Rain, _WorldData} = State) ->
  {reply, already_started, State};

handle_call(start_rain, _From, {started, no_rain, WorldData}) ->
  super_main:make_rain(WorldData),
  {reply, started_rain, {started, raining, WorldData}};

handle_call(start_rain, _From, {stopped, _Rain, _WorldData} = State) ->
  {reply, cant_start_rain, State};

handle_call(start_rain, _From, {started, raining, _WorldData} = State) ->
  {reply, already_raining, State};

handle_call(stop_rain, _From, {started, raining, WorldData}) ->
  super_main:destroy_rain(),
  {reply, rain_stopped, {started, no_rain, WorldData}};

handle_call(stop_rain, _From, {stopped, _Rain, _WorldData} = State) ->
  {reply, cant_stop_rain, State};

handle_call(stop_rain, _From, {started, no_rain, _WorldData} = State) ->
  {reply, already_stopped, State};

handle_call(stop_ants, _From, {started, Rain, State}) ->
  super_main:kill_everyone(),
  {reply, stopped, {stopped, Rain, State}};

handle_call(stop_ants, _From, {stopped, _Rain, _WorldData} = State) ->
  {reply, already_stopped, State};

handle_call(get_data, _From, {StateName, RainState, WorldData} = State) ->
  Width = WorldData#world_data.width,
  Height = WorldData#world_data.height,
  IsStarted = StateName =:= started,
  IsRaining = RainState,

  {reply, { {width, Width}, {height, Height}, {simulation_started, IsStarted}, {rain_started, IsRaining} }, State}.
