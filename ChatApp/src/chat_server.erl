-module(chat_server).
-export([start/0]).

start() ->
    spawn(fun() -> loop([]) end).

loop(Clients) ->
    {ok, ListenSocket} = gen_tcp:listen(1234, [binary, {active, true}]),
    io:format("Server listening on port 1234~n"),
    accept_clients(ListenSocket, Clients).

accept_clients(ListenSocket, Clients) ->
    case gen_tcp:accept(ListenSocket) of
        {ok, ClientSocket} ->
            io:format("New client connected: ~p~n", [ClientSocket]),
            spawn(fun() -> handle_client(ClientSocket, Clients) end),
            accept_clients(ListenSocket, [ClientSocket | Clients]);
        {error, _Reason} ->
            io:format("Error accepting client connection~n")
    end.

handle_client(Socket, Clients) ->
    io:format("New client connected: ~p~n", [Socket]),
    client_loop(Socket, Clients).

client_loop(Socket, Clients) ->
    receive
        {tcp, Socket, Data} ->
            io:format("Received message from client: ~s~n", [Data]),
            broadcast(Socket, Data, Clients),
            client_loop(Socket, Clients);
        {close, Socket} ->
            gen_tcp:close(Socket),
            io:format("Client closed connection: ~p~n", [Socket]),
            NewClients = lists:delete(Socket, Clients),
            client_loop(Socket, NewClients)
    end.

broadcast(SenderSocket, Message, Clients) ->
    [ClientSocket ! {chat, Message} || ClientSocket <- Clients, ClientSocket /= SenderSocket].
