-module(process_jobs).

-export([get_tasks/1]).
-export([create_graph/1]).
-export([get_ordered_tasks/1]).
-export([get_ordered_graph/1]).
-export([create_bash_file/1]).

-record(task, {
	name,
	command,
	requires
}).

get_ordered_tasks(Body) ->
	SortedGraph = get_ordered_graph(Body),
	OrderedTasks = [#{<<"name">> => Task, <<"command">> => Cmd}
				|| {Task, Cmd, _Reqs} <- SortedGraph],
	#{<<"tasks">> => OrderedTasks}.

get_ordered_graph(Body) ->
	Tasks = get_tasks(Body),
	Graph = create_graph(Tasks),
	digraph_utils:topsort(Graph).

get_tasks(Body) ->
	Commands = maps:get(<<"tasks">>, Body),
	[#task{name = maps:get(<<"name">>, C),
		   command = maps:get(<<"command">>, C),
		   requires = maps:get(<<"requires">>, C, [])
		   } || C <- Commands].

create_graph(Tasks) ->
	G = digraph:new(),
	Vertices = add_vertices(G, Tasks),
	add_edges(G, Vertices, Tasks),
	G.

% Add vertices to the graph
add_vertices(G, Tasks) ->
	[{Name, digraph:add_vertex(G, {Name, Cmd, Req})} ||
		#task{name = Name, command = Cmd, requires = Req} <- Tasks].

% Add the edges to the graph
add_edges(G, Vertices, Tasks) ->
	lists:foreach(fun(#task{name = Name, requires = Reqs}) ->
					lists:foreach(fun(R) ->
									V1 = proplists:get_value(Name, Vertices),
									V2 = proplists:get_value(R, Vertices),
									digraph:add_edge(G, V2, V1)
						          end, Reqs)
				  end, Tasks),
	G.

create_bash_file(OrderedTasks) ->
	Cmds = ["#!/usr/bin/env bash"] ++ 
			  [binary_to_list(Task) ++ binary_to_list(Cmd)
				|| {Task, Cmd, _Reqs} <- OrderedTasks],
	LineSep = io_lib:nl(),
    #{<<"script">> => list_to_binary([string:join(Cmds, LineSep) ++ LineSep])}.