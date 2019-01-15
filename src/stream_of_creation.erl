%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 11:25
%%%-------------------------------------------------------------------
-module(stream_of_creation).

-export([ start_link/0,
  part_ready/1,
  notify/3, notify/4, notify/2,
  add_handler/1,
  subtract_handler/1]).

start_link() ->
  {ok, PID} = gen_event:start_link({local, ?MODULE}),

  gen_event:add_handler(?MODULE, creation_handler, []),
  part_ready(?MODULE),
  {ok, PID}.

add_handler(Handler) ->
  gen_event:add_handler(?MODULE, Handler, []).

subtract_handler(Handler) ->
  gen_event:delete_handler(?MODULE, Handler, []).

part_ready(Part) ->
  gen_event:notify(?MODULE, {Part, ready}).

notify(Name, Action, State) ->
  gen_event:notify(?MODULE, {Name, Action, State}).

notify(Name, PID, Action, State) ->
  gen_event:notify(?MODULE, {Name, PID, Action, State}).

notify(Name, Action) ->
  gen_event:notify(?MODULE,{Name, Action}).