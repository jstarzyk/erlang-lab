%%%-------------------------------------------------------------------
%%% @author jakub
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. maj 2018 14:13
%%%-------------------------------------------------------------------
-module(pollution_sup_server).
-behaviour(supervisor).
-author("jakub").

%% API
-export([start_link/1, init/1]).

start_link(InitValue) ->
  supervisor:start_link({local, varSupervisor},
    ?MODULE, InitValue).

init(_) ->
  {ok, {
    {one_for_all, 2, 3},
    [ {pollution_sup_server,
      {pollution_sup_server, start_link, [pollution:createMonitor()]},
      permanent, brutal_kill, worker, [pollution_sup_server]}
    ]}
  }.