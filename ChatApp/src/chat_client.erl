-module(chat_client).
-export([start/1]).

start(ServerNode) ->
    case net_kernel:connect_node(ServerNode) of
        {ok, Server} ->
            {ok, ClientSocket} = gen_tcp:connect('localhost', 1234, [binary, {active, true}]),
            io:format("Connected to server at node ~p~n", [Server]),
            spawn(fun input_loop/1, [ClientSocket]),
            spawn(fun receive_loop/1, [ClientSocket]);
        {error, Reason} ->
            io:format("Failed to connect to server node: ~p~n", [Reason]);
        Other ->
            io:format("Unexpected result: ~p~n", [Other])
    end.

input_loop(Socket) ->
    receive
        {tcp, Socket, Message} ->
            io:format("Received message from server: ~s~n", [Message]),
            gen_tcp:send(Socket, Message),
            input_loop(Socket)
    end.

receive_loop(Socket) ->
    receive
        {tcp, Socket, Message} ->
            io:format("Received message from server: ~s~n", [Message]),
            io:format("Sending message to server: ~s~n", [Message]),
            gen_tcp:send(Socket, Message),
            receive_loop(Socket)
    end.