%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @doc
%%% I mean, it's basically an event stream, stream of creation just sounds cooler
%%% @end
%%% Created : 02. Jan 2019 11:25
%%%-------------------------------------------------------------------
-module(stream_of_creation).
%-behavior(gen_event).

-export([ start_link/0,
  part_ready/1,
  notify/3, notify/4,
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

%I'm not entirely sure, whether I won't get any weird bugs (:D) because of add_handler
%let's see, anyways
