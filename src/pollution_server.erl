%%%-------------------------------------------------------------------
%%% @author jakub
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. maj 2018 12:41
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("jakub").

%% API
-export([
  start/0,
  stop/0,
  addStation/2,
  addValue/4,
  removeValue/3,
  getOneValue/3,
  getStationMean/2,
  getDailyMean/2,
  getHourlyStationData/2
]).
-export([init/0]).

-record(monitor, {stations = []}).

loop(Monitor) ->
  receive
    {request, Pid, Function, Arguments} ->
      Result = erlang:apply(pollution, Function, Arguments ++ [Monitor]),
      case is_record(Result, monitor) of
        true -> Pid ! {reply, ok},
          loop(Result);
        false -> Pid ! {reply, Result},
          loop(Monitor)
      end;
    stop -> ok
  end.

%%init() -> Monitor = erlang:apply(pollution, createMonitor, []),
init() -> Monitor = pollution:createMonitor(),
  loop(Monitor).

start() -> register(pollutionServer, spawn_link(?MODULE, init, [])).
%%start() -> Pid = spawn(pollution_server, init, []),
%%  Pid.

stop() -> pollution_server ! stop.

%%init() -> Monitor = pollution:createMonitor(),

call(Function, Arguments) ->
  pollutionServer ! {request, self(), Function, Arguments},
  receive
    {reply, Reply} -> Reply
  end.


addStation(Name, Coordinates) -> call(addStation, [Name, Coordinates]).

addValue(Id, DateTime, Type, Value) -> call(addValue, [Id, DateTime, Type, Value]).

removeValue(Id, DateTime, Type) -> call(removeValue, [Id, DateTime, Type]).

getOneValue(Id, DateTime, Type) -> call(getOneValue, [Id, DateTime, Type]).

getStationMean(Id, Type) -> call(getStationMean, [Id, Type]).

getDailyMean(Type, Date) -> call(getDailyMean, [Type, Date]).

getHourlyStationData(Id, Type) -> call(getHourlyStationData, [Id, Type]).