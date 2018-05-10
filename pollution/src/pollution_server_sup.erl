%%%-------------------------------------------------------------------
%%% @author jakub
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. maj 2018 13:02
%%%-------------------------------------------------------------------
-module(pollution_server_sup).
%%-behaviour(supervisor).
-author("jakub").

%% API
-export([start/0, init/0, stop/0]).


loop() ->
  receive
    {'EXIT', _, _} -> init();
    stop -> ok;
    _ -> loop()
  end.

%%init() -> spawn(pollution_server, start_link, []).
init() ->
  process_flag(trap_exit, true),
  pollution_server:start_link(),
  loop().

start() ->
  register(sup, spawn(?MODULE, init, [])).

stop() ->
  pollution_server:stop(),
  sup ! stop.

