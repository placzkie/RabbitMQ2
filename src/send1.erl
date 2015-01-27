-module(send1).
-include_lib("amqp_client/include/amqp_client.hrl").
-export([main/1]).


main(_) ->
  %%nawiązywanie połączenia
  {ok, Connection} =
    amqp_connection:start(#amqp_params_network{host = "localhost"}),
  %%otwieranie kanału
  {ok, Channel} = amqp_connection:open_channel(Connection),

  %%tworzenie kolejki jeśli nie została jeszcze utworzona
  amqp_channel:call(Channel, #'queue.declare'{queue = <<"hello">>}),

  %%exchange - domyślne "" - wiadomości dostarczane do kolejki o nazwie danej w routing_key(jeśli istnieje)
  amqp_channel:cast(Channel,
    #'basic.publish'{
      exchange = <<"">>,
      routing_key = <<"hello">>},
    #amqp_msg{payload = <<"Hello World!">>}),
  io:format(" [x] Sent 'Hello World!'~n"),

  %%zamykanie kanału
  ok = amqp_channel:close(Channel),
  %%zamykanie połączenia
  ok = amqp_connection:close(Connection),
  ok.