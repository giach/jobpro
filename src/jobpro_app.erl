%% @private
-module(jobpro_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/order", process_req, []},
			{"/script", gen_script, []}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
		env => #{dispatch => Dispatch}
	}),
	jobpro_sup:start_link().

stop(_State) ->
	ok = cowboy:stop_listener(http).
