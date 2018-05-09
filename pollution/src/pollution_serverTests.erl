%%%-------------------------------------------------------------------
%%% @author jakub
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. maj 2018 13:51
%%%-------------------------------------------------------------------
-module(pollution_serverTests).
-author("jakub").

-include_lib("eunit/include/eunit.hrl").

%%-record(result, {type, datetime, value}).
%%-record(station, {name, coordinates, results = []}).
%%-record(monitor, {stations = []}).

startServer() -> pollution_server:start().

stopServer(R) -> pollution_server:stop().

setupStation(Args) -> startServer(),
  erlang:apply(pollution_server, addStation, Args).

addStation_test_() ->
  {setup,
    fun startServer/0,
    fun stopServer/1,
    fun addStation/1}.

addStation(R) ->
  [?assertEqual({reply, ok}, pollution_server:addStation("A",{1,2})),
  ?assertEqual({reply, "station exists"}, pollution_server:addStation("A",{1,2}))].

%%addValue_test() -> setupStation(["A",{1,2}]),
%%  DateTime = calendar:local_time(),
%%  ?assertEqual({reply, ok}, pollution_server:addValue("A", DateTime, "PM10", 30)),
%%  ?assertEqual({reply, "result exists in station"}, pollution_server:addValue("A", DateTime, "PM10", 30)),
%%  ?assertEqual({reply, "cannot add result to nonexistent station"}, pollution_server:addValue("B", DateTime, "PM10", 30)).
%%
%%removeValue_test() -> setupStation(["A",{1,2}]),
%%  DateTime = calendar:local_time(),
%%  ?assertEqual({reply, ok}, pollution_server:removeValue("A", DateTime, "PM10")),
%%  ?assertEqual({reply, "cannot remove result from nonexistent station"}, pollution_server:removeValue("A", DateTime, "PM10")).
%%
%%getOneValue_test() -> setupStation(["A",{1,2}]),
%%  DateTime = calendar:local_time(),
%%  pollution_server:addValue("A", DateTime, "PM10", 60),
%%  pollution_server:addValue("A", DateTime, "PM2.5", 14),
%%  pollution_server:addValue("A", DateTime, "temp", 23),
%%  ?assertEqual({reply, {result,"PM2.5", DateTime,14}}, pollution_server:getOneValue("A", DateTime, "PM2.5")),
%%  ?assertEqual({reply, "station does not exist"}, pollution_server:getOneValue("B", DateTime, "PM2.5")),
%%  ?assertEqual({reply, "no result"}, pollution_server:getOneValue("A", DateTime, "PM10")).
%%
%%getStationMean_test() -> setupStation(["A",{1,2}]),
%%  DateTime = calendar:local_time(),
%%  pollution_server:addValue("A", {{2018,4,11},{9,0,0}}, "PM10", 60),
%%  pollution_server:addValue("A", DateTime, "PM2.5", 14),
%%  pollution_server:addValue("A", DateTime, "temp", 23),
%%  pollution_server:addValue("A", {{2018,4,11},{10,0,0}}, "PM10", 20),
%%  pollution_server:addValue("A", {{2018,4,11},{11,0,0}}, "PM10", 15),
%%  pollution_server:addValue("A", calendar:local_time(), "PM10", 25),
%%  ?assertEqual({reply, 30.0}, pollution_server:getStationMean("A", "PM10")),
%%  pollution_server:addStation("B",{3,4}),
%%  ?assertEqual({reply, "no results"}, pollution_server:getStationMean("B", "PM10")),
%%  ?assertEqual({reply, "station does not exist"}, pollution_server:getStationMean("C", "PM10")).
%%
%%getDailyMean_test() -> startServer(),
%%  pollution_server:addStation("A",{1,2}),
%%  pollution_server:addStation("B",{3,4}),
%%  pollution_server:addValue("A", {{2018,4,11},{10,0,0}}, "PM10", 60),
%%  pollution_server:addValue("A", {{2018,4,11},{11,0,0}}, "PM10", 55),
%%  pollution_server:addValue("A", {{2018,4,11},{12,0,0}}, "PM10", 50),
%%  pollution_server:addValue("B", {{2018,4,11},{10,0,0}}, "PM10", 80),
%%  pollution_server:addValue("B", {{2018,4,11},{11,0,0}}, "PM10", 75),
%%  pollution_server:addValue("B", {{2018,4,11},{12,0,0}}, "PM10", 70),
%%  pollution_server:addValue("B", {{2018,4,12},{12,0,0}}, "PM10", 70),
%%  ?assertEqual({reply, 65.0}, pollution_server:getDailyMean("PM10", {2018,4,11})),
%%  ?assertEqual({reply, "no results"}, pollution_server:getDailyMean("PM2.5", {2018,4,11})).
%%
%%getHourlyStationData_test() -> setupStation(["A",{1,2}]),
%%  pollution_server:addValue("A", {{2018,4,11},{10,0,0}}, "PM10", 60),
%%  pollution_server:addValue("A", {{2018,4,11},{11,0,0}}, "PM10", 55),
%%  pollution_server:addValue("A", {{2018,4,11},{12,0,0}}, "PM10", 50),
%%  pollution_server:addValue("A", {{2018,4,11},{10,20,0}}, "PM10", 20),
%%  pollution_server:addValue("A", {{2018,4,11},{10,40,0}}, "PM10", 10),
%%  pollution_server:addValue("A", {{2018,4,12},{11,0,0}}, "PM10", 45),
%%  ?assertEqual({reply, [{10,30.0}, {11,50.0}, {12,50.0}]}, pollution_server:getHourlyStationData("A", "PM10")),
%%  ?assertEqual({reply, []}, pollution_server:getHourlyStationData("A", "PM2.5")),
%%  ?assertEqual({reply, "station does not exist"}, pollution_server:getHourlyStationData("B", "PM10")).
