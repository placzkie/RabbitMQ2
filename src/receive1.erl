%%#!/usr/bin/env escript
%%! -pz ./amqp_client ./rabbit_common ./amqp_client/ebin ./rabbit_common/ebin
-module(receive1).
-include_lib("amqp_client/include/amqp_client.hrl").
-export([main/1]).

main(_) ->
  {ok, Connection} =
    amqp_connection:start(#amqp_params_network{host = "localhost"}),
  {ok, Channel} = amqp_connection:open_channel(Connection),

  amqp_channel:call(Channel, #'queue.declare'{queue = <<"hello">>}),
  io:format(" [*] Waiting for messages. To exit press CTRL+C~n"),

  amqp_channel:subscribe(Channel, #'basic.consume'{queue = <<"hello">>,
    no_ack = true}, self()),
  receive
    #'basic.consume_ok'{} -> ok
  end,
  loop(Channel).


loop(Channel) ->
  receive
    {#'basic.deliver'{}, #amqp_msg{payload = Body}} ->
      io:format(" [x] Received ~p~n", [Body]),
      loop(Channel)
  end.