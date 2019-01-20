%%%-------------------------------------------------------------------
%%% @author karolinabogacka
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Jan 2019 05:37
%%%-------------------------------------------------------------------
-module(user).
-author("karolinabogacka").
-include("parametres.hrl").

%% API
-export([main/0]).

loop() ->
  P = string:strip(io:get_line("command>"),right,$\n),
  io:format("~w alleluja",P),
  case P of
    "sa." ->
      io:fwrite("Zacząłeś ruch mrówek. ~n",[]),
      controls:start_ants();
    "ea." ->
      io:fwrite("Zakończyłeś ruch mrówek"),
      controls:stop_ants();
    "sr." ->
      io:fwrite("Zacząłeś deszcz"),
      controls:start_rain();
    "er." ->
      io:fwrite("Zakończyłeś deszcz"),
      controls:stop_rain();
    "gd." ->
      io:fwrite("Dane symulacji"),
      controls:get_data()
  end,
  io:fwrite("Aplikacja symulująca zachowanie mrówek w trakcie deszczu. ~n",[]),
  io:fwrite("Wpisz sa żeby rozpocząć ruch mrówek, ea żeby go zakończyć. ~n",[]),
  io:fwrite("Wpisz sr żeby rozpocząć deszcz, er żeby go zakończyć. ~n",[]),
  io:fwrite("Wpisz gd aby uzyskać dane symulacji. ~n",[]),
  loop().

main()->
    observer:start(),
    io:fwrite("Aplikacja symulująca zachowanie mrówek w trakcie deszczu. ~n",[]),
    io:fwrite("Wpisz sa żeby rozpocząć ruch mrówek, ea żeby go zakończyć. ~n",[]),
    io:fwrite("Wpisz sr żeby rozpocząć deszcz, er żeby go zakończyć. ~n",[]),
    io:fwrite("Wpisz gd aby uzyskać dane symulacji. ~n",[]),
    loop().
