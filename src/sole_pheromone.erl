%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2019 13:10
%%%-------------------------------------------------------------------
-module(sole_pheromone).
-author("karolinabogacka").
-behavior(gen_server).
-include("parametres.hrl").


%% API
-export([ init/1, handle_call/3, terminate/2, code_change/3, handle_cast/2, handle_info/2, start_link/1]).

start_link(InitState) ->
  gen_server:start_link(?MODULE, InitState, []).

init({WorldData, Place, FoodPlace}) ->
  State = #pheromone{pid = self(), place = Place, food_place = FoodPlace, size = WorldData },
  stream_of_creation:notify(pheromone, has_been_placed, State),
  erlang:send_after(?PHEROMONE_TIME, self(), timeout_shutdown),
  {ok, State}.

handle_call({are_you_at, Place}, _From, State) ->
  {X, Y} = {(State#pheromone.place)#place.x, (State#pheromone.place)#place.y},
  Ans = case {Place#place.x, Place#place.y} of
             {X, Y} -> true;
             _      -> false
           end,
  {reply, Ans, State};

handle_call({are_you_near, Place}, _From, State) ->
  %stream_of_creation:notify( ant, a_bug_is_found, State#pheromone.place),
  {X, Y} = {(State#pheromone.place)#place.x, (State#pheromone.place)#place.y},
  Ans = if erlang:abs(Place#place.x - X) < 4, erlang:abs(Place#place.y - Y) < 4
              -> State#pheromone.place;
             true
               -> false
           end,
  {reply, Ans, State};

handle_call({where_is_food}, _From, State) ->
  Ans = State#pheromone.food_place,
  {reply, Ans, State}.

terminate(_, _State) ->
  ok.

code_change(_Old, State, _) ->
  {ok, State}.

handle_cast(_Ask, State) ->
  {noreply, State}.

handle_info(timeout_shutdown, State) ->
  stream_of_creation:notify(pheromone, the_scent_is_gone, State),
  {stop, normal, State};

handle_info(_Info, State) ->
  {noreply, State}.
