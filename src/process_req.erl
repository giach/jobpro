-module(process_req).


-export([init/2]).


init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	HasBody = cowboy_req:has_body(Req0),
	Resp = maybe_process_job(Method, HasBody, Req0),
	{ok, Resp, Opts}.


maybe_process_job(<<"POST">>, true, Req0) ->
	{ok, PostVals, _Req} = cowboy_req:read_body(Req0),
	Body = jsx:decode(PostVals),
	Tasks = process_jobs:get_ordered_tasks(Body),
	RespBody = jsx:encode(Tasks),
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, RespBody, Req0);

maybe_process_job(<<"POST">>, false, Req) ->
	cowboy_req:reply(400, [], <<"Missing body.">>, Req);

maybe_process_job(_Method, _hasBody, Req) ->
	cowboy_req:reply(405, Req).

