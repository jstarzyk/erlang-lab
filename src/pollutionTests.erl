%%%-------------------------------------------------------------------
%%% @author jakub
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. kwi 2018 13:07
%%%-------------------------------------------------------------------
-module(pollutionTests).
-compile(export_all).
-author("jakub").

-include_lib("eunit/include/eunit.hrl").

-record(result, {type, datetime, value}).
-record(station, {name, coordinates, results = []}).
-record(monitor, {stations = []}).

setupMonitor() -> pollution:createMonitor().

setupStation(Args) -> M = setupMonitor(),
  apply(fun pollution:addStation/3, Args ++ [M]).

createMonitor_test() ->
  ?assertEqual(#monitor{}, pollution:createMonitor()).

addStation_test() -> M = setupMonitor(),
  ?assertMatch({monitor,[{station,"A",{1,2},[]}]}, pollution:addStation("A",{1,2},M)),
  M1 = pollution:addStation("A",{1,2},M),
  ?assertEqual("station exists", pollution:addStation("A",{1,2},M1)),
  ?assertEqual("station exists", pollution:addStation("B",{1,2},M1)),
  ?assertEqual("station exists", pollution:addStation("A",{3,4},M1)).

addValue_test() -> M1 = setupStation(["A",{1,2}]),
  DateTime = calendar:local_time(),
  M2 = pollution:addValue("A", DateTime, "PM10", 60, M1),
  S = lists:nth(1, M2#monitor.stations),
  ?assert(lists:member({result,"PM10", DateTime,60}, S#station.results)),
  ?assertEqual("result exists in station", pollution:addValue("A", DateTime, "PM10", 30, M2)),
  ?assertEqual("cannot add result to nonexistent station", pollution:addValue("B", DateTime, "PM10", 30, M2)).

removeValue_test() -> M = setupStation(["A",{1,2}]),
  DateTime = calendar:local_time(),
  M1 = pollution:addValue("A", DateTime, "PM10", 60, M),
  ?assertEqual(M, pollution:removeValue("A", DateTime, "PM10", M1)),
  ?assertEqual(M, pollution:removeValue("A", DateTime, "PM10", M)).

getOneValue_test() -> M = setupStation(["A",{1,2}]),
  DateTime = calendar:local_time(),
  M1 = pollution:addValue("A", DateTime, "PM10", 60, M),
  M2 = pollution:addValue("A", DateTime, "PM2.5", 14, M1),
  M3 = pollution:addValue("A", DateTime, "temp", 23, M2),
  ?assertEqual({result,"PM2.5", DateTime,14}, pollution:getOneValue("A", DateTime, "PM2.5", M3)).

getStationMean_test() -> M = setupStation(["A",{1,2}]),
  DateTime = calendar:local_time(),
  M1 = pollution:addValue("A", {{2018,4,11},{9,0,0}}, "PM10", 60, M),
  M2 = pollution:addValue("A", DateTime, "PM2.5", 14, M1),
  M3 = pollution:addValue("A", DateTime, "temp", 23, M2),
  M4 = pollution:addValue("A", {{2018,4,11},{10,0,0}}, "PM10", 20, M3),
  M5 = pollution:addValue("A", {{2018,4,11},{11,0,0}}, "PM10", 15, M4),
  M6 = pollution:addValue("A", calendar:local_time(), "PM10", 25, M5),
  ?assertEqual(30.0, pollution:getStationMean("A", "PM10", M6)).

getDailyMean_test() -> M = setupMonitor(),
  M1 = pollution:addStation("A",{1,2},M),
  M2 = pollution:addStation("B",{3,4},M1),
  M3 = pollution:addValue("A", {{2018,4,11},{10,0,0}}, "PM10", 60, M2),
  M4 = pollution:addValue("A", {{2018,4,11},{11,0,0}}, "PM10", 55, M3),
  M5 = pollution:addValue("A", {{2018,4,11},{12,0,0}}, "PM10", 50, M4),
  M6 = pollution:addValue("B", {{2018,4,11},{10,0,0}}, "PM10", 80, M5),
  M7 = pollution:addValue("B", {{2018,4,11},{11,0,0}}, "PM10", 75, M6),
  M8 = pollution:addValue("B", {{2018,4,11},{12,0,0}}, "PM10", 70, M7),
  M9 = pollution:addValue("B", {{2018,4,12},{12,0,0}}, "PM10", 70, M8),
  ?assertEqual(65.0, pollution:getDailyMean("PM10", {2018,4,11}, M9)).

getHourlyStationData_test() -> M = setupStation(["A",{1,2}]),
  M3 = pollution:addValue("A", {{2018,4,11},{10,0,0}}, "PM10", 60, M),
  M4 = pollution:addValue("A", {{2018,4,11},{11,0,0}}, "PM10", 55, M3),
  M5 = pollution:addValue("A", {{2018,4,11},{12,0,0}}, "PM10", 50, M4),
  M6 = pollution:addValue("A", {{2018,4,11},{10,20,0}}, "PM10", 20, M5),
  M7 = pollution:addValue("A", {{2018,4,11},{10,40,0}}, "PM10", 10, M6),
  M8 = pollution:addValue("A", {{2018,4,12},{11,0,0}}, "PM10", 45, M7),
  ?assertEqual([{10,30.0}, {11,50.0}, {12,50.0}], pollution:getHourlyStationData("A", "PM10", M8)).
