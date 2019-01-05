%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @doc
%%%
%%% @end
%%% Created : 01. Jan 2019 19:17
%%%-------------------------------------------------------------------
-module(sole_ant).

-behavior(gen_statem).
-include("parametres.hrl").


%% API
-export([ start_link/1, init/1, terminate/3, callback_mode/0, handle_info/3, code_change/4, loop/3, handle_call/3]).

start_link(InState) ->
    gen_statem:start_link(?MODULE, InState, []).

init({WorldData, Place}) ->

    State = #ant{pid = self(), place = Place, colony_place = Place, size = WorldData},

    stream_of_creation:notify( ant, an_ant_is_born, State),
%you can change timeout
%and, by proxy, the amount of time it takes to run a simulation
%here                    |   |
%                       \     /
%                        \   /
    {ok, loop, State, 300}.

terminate(_, _SName, State) ->
  stream_of_creation:notify(ant, an_ant_has_died, State),
  ok.

callback_mode() ->
  state_functions.

handle_info(stop_sign, _SName, State) ->
  {stop, normal, State};

handle_info(rain_shutdown, _State, State) ->
  stream_of_creation:notify(ant, hit_by_rain, State),
  {stop, normal, State};

handle_info(_Info, SName, State) ->
  {next_state, SName, State}.

code_change(_Old, SName, State, _Add) ->
  {ok, SName, State}.

loop(timeout, _, State) ->
   NewPlace = moves:next_to_target(State#ant.size, State#ant.place, State#ant.target_pos),

   AskForIt = case State#ant.target_pos of
                {target_pos, undefined, undefined} -> true;
                {target_pos, X, Y} when X == NewPlace#place.x,
                             Y == NewPlace#place.y ->
                             true;
                {target_pos, _X, _Y} ->
                             false
                         end,

   NState = case AskForIt of
               true  ->
                 EntityMet = what_is_at(NewPlace, State#ant.colony_place),
                 PheromoneNear = pheromone_near(NewPlace),
                 affect_target(EntityMet),
                 {NewTarget, FoodPosition} = get_new_target(State, EntityMet, NewPlace, PheromoneNear),
                 State#ant{place = NewPlace, target_pos = NewTarget, food_place = FoodPosition};
               false ->
                 State#ant{place = NewPlace}
             end,

   if
     State#ant.food_place /= undefined, NState#ant.colony_place /= NState#ant.place ->
      super_pheromone:place_pheromone(State#ant.size, State#ant.place, State#ant.food_place);
     true ->
      false
   end,

  stream_of_creation:notify(ant, move, NState),
  {next_state, loop,NState,300}.

get_new_target(State, {nothing}, _NewPlace, {position, X, Y}) ->
  stream_of_creation:notify(ant, pheromone_noticed, State),
  {#target_pos{x = X, y = Y}, undefined};

get_new_target(_State, {nothing}, _NewPlace, _Pheromone) ->
  {#target_pos{x = undefined, y = undefined}, undefined};

get_new_target(_State, {colony, _ColonyPlace}, _NewPlace, _Pheromone) ->
  {#target_pos{x = undefined, y = undefined}, undefined};

get_new_target(State, {food, _Food}, NewPlace, _Pheromone) ->
  {#target_pos{x = State#ant.colony_place#place.x, y = State#ant.colony_place#place.y}, NewPlace};

get_new_target(State, {pheromone, Pheromone}, _NewPosition, _Pheromone) ->
  FoodPosition = where_is_food(Pheromone),
  stream_of_creation:notify(ant, following_pheromone, State),
  {#target_pos{x = FoodPosition#place.x, y = FoodPosition#place.y}, undefined}.

affect_target({food, Food}) ->
  gen_server:call(Food, {eat});

affect_target(_) ->
  ok.

what_is_at(Place, ColonyPlace) when Place#place.x == ColonyPlace#place.x,
  Place#place.y == ColonyPlace#place.y ->
  {colony, ColonyPlace};

what_is_at(Place, _ColonyPlace) ->

  AllFood = supervisor:which_children(super_food),
  AllPheromone = supervisor:which_children(super_pheromone),
  what_is_at(Place, AllFood, AllPheromone).

what_is_at(Place, [{_Id, Food, _Type, _Modules} | Rest ], Pheromones) ->

  try gen_server:call(Food, {are_you_at, Place}) of
    true ->
      {food, Food};
    false ->
      what_is_at(Place, Rest, Pheromones)
  catch
    exit: _Reason -> what_is_at(Place, Rest)

  end;

what_is_at(Place, [], [{_Id, Pheromone, _Type, _Modules} | Rest ]) ->

  try gen_server:call(Pheromone, {are_you_at, Place}) of
    true ->
      {pheromone, Pheromone};
    false ->
      what_is_at(Place, [], Rest)
  catch
    exit: _Reason -> what_is_at(Place, Rest)

  end;

what_is_at(_Position, [], []) ->
  {nothing}.


pheromone_near(Position) ->
  AllPheromone = supervisor:which_children(super_pheromone),
  pheromone_near(Position, AllPheromone).


pheromone_near(Place, [{_Id, Pheromone, _Type, _Modules} | Rest ]) ->
  try gen_server:call(Pheromone, {are_you_near, Place}) of
    {place, X, Y} ->
      #place{x = X, y = Y};
    false ->
      pheromone_near(Place, Rest)
  catch
    exit: _Reason -> pheromone_near(Place, Rest)
  end;

pheromone_near(_Place, []) ->
  {nothing}.

where_is_food(Pheromone) ->
  try gen_server:call(Pheromone, {where_is_food}) of
    FoodPosition -> FoodPosition
  catch
    exit: _Reason -> where_is_food(Pheromone)
  end.

handle_event({are_you_there, Place}, _From, State) ->
  {X, Y} = {(State#ant.place)#place.x, (State#ant.place)#place.y},
  Is = case {Place#place.x, Place#place.y} of
         {X, Y} -> true;
          _     -> false
       end,
  case Is of
    true ->
      erlang:send_after(15, self(), rain_shutdown);
    false -> stream_of_creation:notify(ant, ant_not_hit_by_rain, State)
  end,
  {ok, loop, State, 300}.
