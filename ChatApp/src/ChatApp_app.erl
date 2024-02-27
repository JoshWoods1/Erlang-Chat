%%%-------------------------------------------------------------------
%% @doc ChatApp public API
%% @end
%%%-------------------------------------------------------------------

-module(ChatApp_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ChatApp_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
