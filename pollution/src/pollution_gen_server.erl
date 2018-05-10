%%%-------------------------------------------------------------------
%%% @author jakub
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. maj 2018 13:54
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-behaviour(gen_server).
-author("jakub").

%% API
-export([start_link/1, init/1, handle_call/3,
  addStation/2,
  addValue/4,
  removeValue/3,
  getOneValue/3,
  getStationMean/2,
  getDailyMean/2,
  getHourlyStationData/2]).

-record(monitor, {stations = []}).


addStation(Name, Coordinates) -> gen_server:call(pollution_gen_server, {addStation, [Name, Coordinates]}).

addValue(Id, DateTime, Type, Value) -> gen_server:call(pollution_gen_server, {addValue, [Id, DateTime, Type, Value]}).

removeValue(Id, DateTime, Type) -> gen_server:call(pollution_gen_server, {removeValue, [Id, DateTime, Type]}).

getOneValue(Id, DateTime, Type) -> gen_server:call(pollution_gen_server, {getOneValue, [Id, DateTime, Type]}).

getStationMean(Id, Type) -> gen_server:call(pollution_gen_server, {getStationMean, [Id, Type]}).

getDailyMean(Type, Date) -> gen_server:call(pollution_gen_server, {getDailyMean, [Type, Date]}).

getHourlyStationData(Id, Type) -> gen_server:call(pollution_gen_server, {getHourlyStationData, [Id, Type]}).

handle_call({Function, Arguments}, _From, Monitor) ->
  Result = erlang:apply(pollution, Function, Arguments ++ [Monitor]),
  case is_record(Result, monitor) of
    true -> {reply, ok, Result};
    false -> {reply, Result, Monitor}
  end.

start_link(InitialValue) ->
  gen_server:start_link(
    {local, pollution_gen_server},
    pollution_gen_server,
    InitialValue, []).

init(_) ->
  {ok, pollution:createMonitor()}.