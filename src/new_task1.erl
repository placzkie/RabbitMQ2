-module(new_task1).
-include_lib("amqp_client/include/amqp_client.hrl").
-export([main/1]).

main(Argv) ->
  {ok, Connection} =
    amqp_connection:start(#amqp_params_network{host = "localhost"}),
  {ok, Channel} = amqp_connection:open_channel(Connection),

  %%tworzenie kolejki, durable - kolejka po restarcie serwera będzie nadal istniała
  amqp_channel:call(Channel, #'queue.declare'{queue = <<"task_queue">>,
    durable = true}),

  Message = case Argv of
              [] -> <<"Hello World!">>;
              Msg -> list_to_binary(string:join(Msg, " "))
            end,
  amqp_channel:cast(Channel,
    #'basic.publish'{
      exchange = <<"">>,
      routing_key = <<"task_queue">>},
    %%persistent message
    #amqp_msg{props = #'P_basic'{delivery_mode = 2},
      payload = Message}),
  io:format(" [x] Sent ~p~n", [Message]),
  ok = amqp_channel:close(Channel),
  ok = amqp_connection:close(Connection),
  ok.