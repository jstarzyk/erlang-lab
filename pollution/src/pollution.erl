%%%-------------------------------------------------------------------
%%% @author jakub
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. kwi 2018 11:57
%%%-------------------------------------------------------------------
-module(pollution).
-author("jakub").

%% API
-export([
  createMonitor/0,
  addStation/3,
  addValue/5,
  removeValue/4,
  getOneValue/4,
  getStationMean/3,
  getDailyMean/3,
  getHourlyStationData/3
]).

-record(result, {type, datetime, value}).
-record(station, {name, coordinates, results = []}).
-record(monitor, {stations = []}).

stationExists(Id, Monitor) ->
  case is_tuple(Id) of
    true -> lists:keyfind(Id, #station.coordinates, Monitor#monitor.stations);
    false -> lists:keyfind(Id, #station.name, Monitor#monitor.stations)
  end.

createMonitor() -> #monitor{}.

addStation(Name, Coordinates, Monitor) ->
  FoundSame = lists:any(fun(Station) ->
    ((Station#station.name == Name) or (Station#station.coordinates == Coordinates)) end,
    Monitor#monitor.stations),
  case FoundSame of
%%    true -> erlang:error("station exists");
    true -> "station exists";
    false -> S = Monitor#monitor.stations ++ [#station{name = Name, coordinates = Coordinates}],
      Monitor#monitor{stations = S}
  end.

addValue(Id, DateTime, Type, Value, Monitor) ->
  case stationExists(Id, Monitor) of
%%    false -> erlang:error("cannot add result to nonexistent station");
    false -> "cannot add result to nonexistent station";
    Station -> Result = #result{type = Type, datetime = DateTime, value = Value},
      FoundSame = lists:any(fun(Result) ->
        ((Result#result.type == Type) and (Result#result.datetime == DateTime)) end,
        Station#station.results),
      case FoundSame of
%%        true -> erlang:error("result exists in station");
        true -> "result exists in station";
        false -> UpdatedStation = Station#station{results = Station#station.results ++ [Result]},
          StationList = lists:delete(Station, Monitor#monitor.stations),
          Monitor#monitor{stations = StationList ++ [UpdatedStation]}
      end
  end.

findValue(DateTime, Type, Station) ->
  Matching = lists:filter(fun(Result) ->
    ((Result#result.type == Type) and (Result#result.datetime == DateTime)) end,
    Station#station.results),
  case Matching of
    [H | _] -> H;
    [] -> "no result"
  end.

removeValue(Id, DateTime, Type, Monitor) ->
  case stationExists(Id, Monitor) of
%%    false -> erlang:error("cannot remove result from nonexistent station");
    false -> "cannot remove result from nonexistent station";
    Station ->
      case findValue(DateTime, Type, Station) of
        no_result -> Monitor;
        H -> ResultList = lists:delete(H, Station#station.results),
          UpdatedStation = Station#station{results = ResultList},
          StationList = lists:delete(Station, Monitor#monitor.stations),
          Monitor#monitor{stations = StationList ++ [UpdatedStation]}
      end
  end.

getOneValue(Id, DateTime, Type, Monitor) ->
  case stationExists(Id, Monitor) of
    false -> "station does not exist";
%%    false -> erlang:error("station does not exist");
    Station -> findValue(DateTime, Type, Station)
  end.

getStationMean(Id, Type, Monitor) ->
  case stationExists(Id, Monitor) of
    false -> "station does not exist";
%%    false -> erlang:error("station does not exist");
    Station -> Matching = lists:filter(fun(Result) ->
      (Result#result.type == Type) end, Station#station.results),
      case Matching of
        [] -> "no results";
        Results -> Values = [element(#result.value, X) || X <- Results],
          lists:sum(Values) / length(Values)
      end
  end.

getDailyMean(Type, Date, Monitor) ->
  AllResults = lists:flatten([element(#station.results, X) || X <- Monitor#monitor.stations]),
  Filtered = lists:filter(fun(Result) ->
    ((Result#result.type == Type) and (element(1, Result#result.datetime) == Date)) end, AllResults),
  case Filtered of
    [] -> "no results";
    Results -> Values = [element(#result.value, X) || X <- Results],
      lists:sum(Values) / length(Values)
  end.

partitionByHour([], Result) -> Result;
partitionByHour([X | T], []) -> partitionByHour(T, [[X]]);
partitionByHour([X | T], [[C | S] | R]) ->
  case element(1, X) == element(1, C) of
    true  -> partitionByHour(T, [[C | [X] ++ S] | R]);
    false -> partitionByHour(T, [[X], [C | S] | R])
  end.

getHourlyStationData(Id, Type, Monitor) ->
  case stationExists(Id, Monitor) of
%%    false -> erlang:error("station does not exist");
    false -> "station does not exist";
    %%krotka
    Station -> Results = [X || X <- Station#station.results, X#result.type == Type],
      Values = [{element(1, element(2, X#result.datetime)), element(#result.value, X)} || X <- Results],
      Sorted = lists:sort(fun(A, B) -> (element(1, A) =< element(1, B)) end, Values),
      Partitioned = lists:reverse(partitionByHour(Sorted, [])),
      SumSecond = fun(L) -> lists:foldl(fun({H, V}, {_, S}) -> {H, (V + S)} end, {0, 0}, L) end,
      WithLength = lists:map(fun(X) -> {SumSecond(X), length(X)} end, Partitioned),
      lists:map(fun({{H, S}, L}) -> {H, S / L} end, WithLength)
  end.