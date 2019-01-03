%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 13:01
%%%-------------------------------------------------------------------
-module(creation_handler).
-include("parametres.hrl").
-behavior(gen_event).

%% API
-export([ init/1, handle_event/2, terminate/2, handle_call/2, handle_info/2, code_change/3]).

init(_) ->
  {ok, []}.

handle_event(Message, State) ->
  io:format("~w ~n", [Message]),
  {ok, State}.

code_change(_Old, State, _) ->
  {ok, State}.

handle_call(_Ask, State) ->
  {ok, empty, State}.

handle_info(_Inf, State) ->
  {ok, State}.

terminate(_Ar, _State) ->
  ok.